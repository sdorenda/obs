#
#  kafka-user generator (secret specs)
# --

resource "kubernetes_manifest" "kafka_passwords" {
  for_each = var.kafka_users

  manifest = {
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "kafka-client-pwd-${each.key}"
      namespace = kubernetes_namespace.kafka_cluster.metadata[0].name
      labels    = var.labels
    }
    type = "Opaque"
    data = {
      "client-passwords" = base64encode(each.value.password)
    }
  }
}