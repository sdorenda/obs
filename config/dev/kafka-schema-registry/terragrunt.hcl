include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}//stacks/kafka-schema-registry"
}

inputs = {

  # label specs default overrides for (all) entities
  labels = {
    "app.kubernetes.io/managed-by"    = "terraform"
    "app.kubernetes.io/infra-version" = "0.9.6"
    "app.kubernetes.io/instance"      = "dev-experimental"
    "app.kubernetes.io/part-of"       = "kafka-cluster"
    "app.kubernetes.io/sub-stack"     = "kafka-schema-registry"
    "observability.branch"            = "dev-feature"
    "observability.customer"          = "internal"
    "availability.zone"               = "az-3"
    "availability.region"             = "eu-de-2"
    "env"                             = "dev"
  }
}
