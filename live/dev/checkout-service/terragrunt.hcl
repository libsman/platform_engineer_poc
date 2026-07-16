include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(
    find_in_parent_folders("env.hcl")
  ).locals.env
}

terraform {
  source = "${get_repo_root()}/modules/static-web-app"
}

dependency "rg" {
  config_path = "../resource-group"

  mock_outputs = {
    name = "rg-poc-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  name                = "stapp-checkout-service-${local.env}"
  resource_group_name = dependency.rg.outputs.name
  location            = "westeurope"
  tags = {
    env         = local.env
    owner       = "team-payments"
    cost_center = "platform-engineering"
    managed_by  = "terraform"
  }
}
