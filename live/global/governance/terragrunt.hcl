include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/governance"
}

inputs = {
  allowed_locations = ["westeurope", "germanywestcentral", "northeurope"]
  required_tag      = "env"
}
