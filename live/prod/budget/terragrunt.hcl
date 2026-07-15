include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_config = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env        = local.env_config.locals.env
}

terraform {
  source = "${get_repo_root()}/modules/budget"
}

dependency "rg" {
  config_path = "../resource-group"

  mock_outputs = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-poc-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  name                     = "budget-poc-${local.env}"
  resource_group_id        = dependency.rg.outputs.id
  amount                   = local.env_config.locals.budget_amount
  actual_threshold_percent = local.env_config.locals.budget_threshold
  contact_emails           = local.env_config.locals.alert_emails
  start_date               = "2026-07-01T00:00:00Z"
}
