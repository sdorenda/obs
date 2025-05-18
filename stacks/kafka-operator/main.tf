resource "kubernetes_namespace" "kafka_operator" {
  metadata {
    name = "kafka-operator"
    labels = var.labels
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cattle.io/status"],
      metadata[0].annotations["lifecycle.cattle.io/create.namespace-auth"],
    ]
  }
}

# https://artifacthub.io/packages/helm/strimzi/strimzi-kafka-operator
# https://strimzi.io/docs/operators/latest/overview.html
# https://strimzi.io/docs/operators/latest/deploying#config-examples-str
resource "helm_release" "kafka_operator" {
  name       = "kafka-operator"
  repository = "https://strimzi.io/charts"
  chart      = "strimzi-kafka-operator"
  namespace  = kubernetes_namespace.kafka_operator.metadata[0].name
  version    = var.kafka_operator_version

  values = [
    yamlencode({

      defaultImageRegistry   = ""
      defaultImageRepository = "${var.docker_repositories.quay_io}/strimzi"
      watchNamespaces        = var.kafka_operator_watch_namespaces

      operator = {
        enableKRaft = {
          enabled = true
        }
      }
    })
  ]
}
