include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}//stacks/kafka-cluster"
}

inputs = {

  # label specs default overrides for (all) entities
  labels = {
    "app.kubernetes.io/managed-by"    = "terraform"
    "app.kubernetes.io/infra-version" = "0.9.6"
    "app.kubernetes.io/instance"      = "dev-experimental"
    "app.kubernetes.io/part-of"       = "kafka-cluster"
    "observability.branch"            = "dev-feature"
    "observability.customer"          = "internal"
    "availability.zone"               = "az-3"
    "availability.region"             = "eu-de-2"
    "env"                             = "dev"
  }

  # dedicated storage classes + storage volume size
  kafka_jbod_storage_class = "s1-iscsi-xfs-persist"
  kafka_jbod_storage = "5T"

  # dedicated label specs override for nodes only
  kafka_node_labels = {
    "node-role.kubernetes.io/kafka" = "true"
    "topology.kubernetes.io/region" = "eu-de-2"
    "topology.kubernetes.io/zone"   = "az-3"
    "kafka.priority"                = "high"
  }

  # our enforced kafka-node affinity specs (hostnames)
  kafka_nodes = [
    "c1w6.observability.test.pndrs.de",
    "c1w7.observability.test.pndrs.de",
    "c1w8.observability.test.pndrs.de"
  ]

  # kafka user credentials override
  kafka_users = {
    "root" = {
      password  = "m0sfVmtZEn02BCLutdrsOG8NHfFBTwwT"
    },
    "otel-default-rw" = {
      password  = "fhpPbafRkpmLTtVCv2a60cysPpSD6Awt"
    },
    "otel-networking-rw" = {
      password  = "gAa5TVEo0m7pizrTfUDIDspgczSJ58pg"
    },
    "otel-sbx-default-rw" = {
      password  = "BWhC0vAsh9ezB4a0vBXv4EPTCgl2jvFs"
    }
  }
}
