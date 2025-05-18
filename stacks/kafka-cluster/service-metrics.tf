# metric exporter (jmx) service
resource "kubernetes_service_v1" "service_metrics" {
  metadata {
    #  name             = "otel-kafka-metrics" -> "otel-metrics" # forces replacement
    name      = "${var.kafka_cluster_name}-kafka-metrics"
    namespace = kubernetes_namespace.kafka_cluster.metadata[0].name
    labels    = merge(var.labels, {
      "strimzi.io/kind" = "Kafka"
      "strimzi.io/cluster" = var.kafka_cluster_name
    })
  }
  spec {
    port {
      name        = "metrics"
      port        = 9404
      protocol    = "TCP"
      target_port = 9404
    }
    selector = {
      "strimzi.io/name" = "${var.kafka_cluster_name}-kafka"
    }
  }
}