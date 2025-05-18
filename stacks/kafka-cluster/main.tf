resource "kubernetes_namespace" "kafka_cluster" {
  metadata {
    name = "kafka-cluster"
    labels = var.labels
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cattle.io/status"],
      metadata[0].annotations["lifecycle.cattle.io/create.namespace-auth"],
    ]
  }
}
