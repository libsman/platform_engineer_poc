# ---------------------------------------------------------------------------
# Root-Konfiguration: DRY für alle Environments & Units
# - Remote State im Azure Storage (Entra-ID-Auth, KEINE Storage Keys)
# - Provider-Generierung (kein copy/paste in Units)
# - Gemeinsame Governance-Tags
# ---------------------------------------------------------------------------

locals {
  # Environment-Konfiguration aus der Ordnerhierarchie einlesen
  env_config = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env        = local.env_config.locals.env

  project         = "poc"
  location        = "westeurope"
  subscription_id = get_env("ARM_SUBSCRIPTION_ID", "d7263f6e-b3a7-45ef-953d-5aa3b36c8010")

  common_tags = {
    env        = local.env
    owner      = "liban-osman"
    cost_center = "platform-engineering"
    managed_by = "terraform"
    repo       = "libsman/platform_engineer_poc"
  }
}

# --- Remote State: pro Unit ein eigener State-Key --------------------------
remote_state {
  backend = "azurerm"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstatelibsman"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    use_azuread_auth     = true # DevSecOps: RBAC statt Storage Account Keys
  }
}

# --- Provider-Generierung ---------------------------------------------------
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"

  contents = <<EOF
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.37"
    }
  }
}

provider "azurerm" {
  subscription_id                 = "${local.subscription_id}"
  storage_use_azuread             = true
  resource_provider_registrations = "none"

  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}
EOF
}

# --- Inputs, die jede Unit erbt ---------------------------------------------
inputs = {
  location = local.location
  tags     = local.common_tags
}
