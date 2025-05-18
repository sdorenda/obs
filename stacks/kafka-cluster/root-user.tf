# kafka super-user (kafka-root), no acls required.
resource "kubernetes_manifest" "kafka_user_root" {
  manifest = {
    "apiVersion" = "kafka.strimzi.io/v1beta2"
    "kind"       = "KafkaUser"
    "metadata" = {
      "labels" = merge(var.labels,{
        "strimzi.io/cluster" = var.kafka_cluster_name
      })
      "name"      = "kafka-cluster-primary-root"
      "namespace" = kubernetes_namespace.kafka_cluster.metadata[0].name
    }
    "spec" = {
      "authentication" = {
        "type" = "scram-sha-512"
        "password" = {
          "valueFrom" = {
            "secretKeyRef" = {
              "name" = "kafka-client-pwd-root"
              "key"  = "client-passwords"
            }
          }
        }
      }
    }
  }
}
