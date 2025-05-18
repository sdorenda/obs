
# import {
#   to = kubernetes_manifest.kafka_node_pool
#   id = "apiVersion=kafka.strimzi.io/v1beta2,kind=KafkaNodePool,namespace=kafka-cluster,name=controller"
# }

resource "kubernetes_labels" "kafka_node_label" {
  for_each = toset(var.kafka_nodes)

  metadata {
    name = each.key
  }

  api_version = "v1"
  kind        = "Node"
  labels      = var.kafka_node_labels
  force       = true # enforce hcl-based labels, even if the k/v pair already exists

  lifecycle {
    ignore_changes = [labels]  # Ensures only new labels are added, existing ones are not removed
  }
}

resource "kubernetes_manifest" "kafka_node_pool" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind = "KafkaNodePool"
    metadata = {
      name = "controller"
      namespace = kubernetes_namespace.kafka_cluster.metadata[0].name
      "labels" = merge(var.labels,{
        "strimzi.io/cluster" = var.kafka_cluster_name
      })
    }
    spec = {
      replicas = var.kafka_replicas
      roles = [
        "controller",
        "broker"
      ]
      storage = {
        type = "jbod"
        volumes = [
          {
            id = 0
            type = "persistent-claim"
            size = var.kafka_jbod_storage
            class = var.kafka_jbod_storage_class
            deleteClaim = var.kafka_jbod_storage_delete_claim
          }
        ]
      }
      resources = {
        requests = {
          memory = "512Mi"
          cpu = "0.050"
        }
        limits = {
          memory = var.kafka_res_limit_memory
          cpu = var.kafka_res_limit_cpus
        }
      }
      template = {
        pod = {
          affinity = {
            nodeAffinity = {
              requiredDuringSchedulingIgnoredDuringExecution = {
                nodeSelectorTerms = [
                  {
                    matchExpressions = [
                      {
                        key = "node-role.kubernetes.io/kafka"
                        operator = "In"
                        values = [
                          "true"
                        ]
                      }
                    ]
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}
