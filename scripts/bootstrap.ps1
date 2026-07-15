<#
.SYNOPSIS
    Day-Zero-Bootstrap für das Platform-Engineering-PoC.
    Erstellt die minimalen Ressourcen, die VOR Terraform existieren müssen:
      1. Resource Group + Storage Account für Terraform Remote State
         (Shared-Key-Auth deaktiviert -> nur Entra ID RBAC)
      2. Entra App Registration mit Federated Credentials (GitHub OIDC)
         -> KEINE Client Secrets, nirgends.
      3. Least-Privilege-RBAC für die CI-Identity
      4. Resource-Provider-Registrierung (CI-Identity hat kein Recht dazu)
    Idempotent: kann mehrfach ausgeführt werden.
#>

$ErrorActionPreference = "Stop"

# --- Konfiguration -----------------------------------------------------------
$Location        = "westeurope"
$StateRg         = "rg-tfstate"
$StateSa         = "sttfstatelibsman"
$StateContainer  = "tfstate"
$AppName         = "github-oidc-platform-poc"
# GitHub verwendet das neue immutable OIDC-Subject-Format: owner@ownerId/repo@repoId
$GithubRepo      = "libsman@181856274/platform_engineer_poc@1301910177"

$SubscriptionId = az account show --query id -o tsv
$MyObjectId     = az ad signed-in-user show --query id -o tsv
Write-Host "Subscription: $SubscriptionId"

# --- 1. Resource Provider registrieren ---------------------------------------
Write-Host "`n[1/5] Registriere Resource Provider..."
foreach ($ns in @("Microsoft.Web", "Microsoft.OperationalInsights", "Microsoft.Insights",
                  "Microsoft.Consumption", "Microsoft.PolicyInsights", "Microsoft.Storage",
                  "Microsoft.CostManagement", "Microsoft.AlertsManagement", "Microsoft.ManagedIdentity")) {
    az provider register --namespace $ns --wait | Out-Null
    Write-Host "  registered: $ns"
}

# --- 2. State Storage ---------------------------------------------------------
Write-Host "`n[2/5] Erstelle State-Storage (Entra-ID-only, kein Key-Zugriff)..."
az group create --name $StateRg --location $Location `
    --tags env=global owner=liban-osman cost_center=platform-engineering managed_by=bootstrap | Out-Null

az storage account create `
    --name $StateSa `
    --resource-group $StateRg `
    --location $Location `
    --sku Standard_LRS `
    --kind StorageV2 `
    --access-tier Hot `
    --min-tls-version TLS1_2 `
    --allow-blob-public-access false `
    --allow-shared-key-access false `
    --tags env=global owner=liban-osman cost_center=platform-engineering managed_by=bootstrap | Out-Null

# Blob-Versionierung: Schutz vor State-Korruption
az storage account blob-service-properties update `
    --account-name $StateSa --resource-group $StateRg `
    --enable-versioning true | Out-Null

# Eigener User braucht Data-Plane-Zugriff für lokale Terragrunt-Runs
az role assignment create --assignee $MyObjectId `
    --role "Storage Blob Data Contributor" `
    --scope "/subscriptions/$SubscriptionId/resourceGroups/$StateRg/providers/Microsoft.Storage/storageAccounts/$StateSa" 2>$null | Out-Null

Start-Sleep -Seconds 20 # RBAC-Propagation abwarten
az storage container create --name $StateContainer --account-name $StateSa --auth-mode login | Out-Null
Write-Host "  Storage: $StateSa / Container: $StateContainer"

# --- 3. App Registration + Federated Credentials (OIDC) -----------------------
Write-Host "`n[3/5] Erstelle GitHub-OIDC-Identity..."
$AppId = az ad app list --display-name $AppName --query "[0].appId" -o tsv
if (-not $AppId) {
    $AppId = az ad app create --display-name $AppName --query appId -o tsv
}
$SpId = az ad sp list --filter "appId eq '$AppId'" --query "[0].id" -o tsv
if (-not $SpId) {
    $SpId = az ad sp create --id $AppId --query id -o tsv
}
Write-Host "  App (Client) ID: $AppId"

# Federated Credentials: exakt zugeschnitten auf Repo + Kontext (kein Wildcard)
$subjects = @{
    "gh-pull-request" = "repo:${GithubRepo}:pull_request"
    "gh-env-dev"      = "repo:${GithubRepo}:environment:dev"
    "gh-env-prod"     = "repo:${GithubRepo}:environment:prod"
}
$existing = az ad app federated-credential list --id $AppId --query "[].name" -o tsv
foreach ($name in $subjects.Keys) {
    if ($existing -notcontains $name) {
        $params = @{
            name      = $name
            issuer    = "https://token.actions.githubusercontent.com"
            subject   = $subjects[$name]
            audiences = @("api://AzureADTokenExchange")
        } | ConvertTo-Json -Compress
        az ad app federated-credential create --id $AppId --parameters $params.Replace('"', '\"') | Out-Null
        Write-Host "  federated credential: $name -> $($subjects[$name])"
    }
}

# --- 4. Least-Privilege-RBAC für die CI-Identity -------------------------------
Write-Host "`n[4/5] RBAC für CI-Identity..."
$roles = @(
    @{ role = "Contributor";                     scope = "/subscriptions/$SubscriptionId" },
    @{ role = "Resource Policy Contributor";     scope = "/subscriptions/$SubscriptionId" },
    @{ role = "User Access Administrator";       scope = "/subscriptions/$SubscriptionId" },
    @{ role = "Storage Blob Data Contributor";   scope = "/subscriptions/$SubscriptionId/resourceGroups/$StateRg/providers/Microsoft.Storage/storageAccounts/$StateSa" }
)
foreach ($r in $roles) {
    az role assignment create --assignee-object-id $SpId --assignee-principal-type ServicePrincipal `
        --role $r.role --scope $r.scope 2>$null | Out-Null
    Write-Host "  $($r.role)"
}

# --- 5. Zusammenfassung --------------------------------------------------------
$TenantId = az account show --query tenantId -o tsv
Write-Host @"

[5/5] Bootstrap fertig. GitHub Repository Variables setzen:
  AZURE_CLIENT_ID       = $AppId
  AZURE_TENANT_ID       = $TenantId
  AZURE_SUBSCRIPTION_ID = $SubscriptionId
"@
