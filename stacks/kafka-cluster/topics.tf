locals {
  topics = {
    sbx-logs-normalized = {
      partitions = 1
      replicas = 3
    }
    sbx-logs-ingest = {
      partitions = 1
      replicas = 3
    }
    otel-traces = {
      partitions = 1
      replicas = 3
    }
    otel-metrics = {
      partitions = 1
      replicas = 3
    }
    otel-logs = {
      partitions = 1
      replicas = 3
    }
    otel-networking-vedge-ber-az02-traces = {
      partitions = 5
      replicas = 3
    }
    otel-networking-vedge-ber-az02-metrics = {
      partitions = 5
      replicas = 3
    }
    otel-networking-vedge-ber-az02-logs = {
      partitions = 5
      replicas = 3
    }
  }
}

resource "kubernetes_manifest" "kafka_topics" {
  for_each = local.topics
  manifest = {
    "apiVersion" = "kafka.strimzi.io/v1beta2"
    "kind"       = "KafkaTopic"
    "metadata" = {
      "labels" = merge(var.labels, {
        "strimzi.io/cluster" = var.kafka_cluster_name
      })
      "name"      = each.key
      "namespace" = kubernetes_namespace.kafka_cluster.metadata[0].name
    }
    "spec" = {
      "config" = {
        # should always be set to "delete"
        "cleanup.policy" = "delete"
        # (600000ms=10min, 1800000=30min, 3600000=60min, 600000ms=120min, 604800000=7d, 864000000=10d, 1728000000=20d)
        "retention.ms" = 3600000
        # (1073741824=1gb -> default)
        "segment.bytes" = 1073741824
      }
      # should always be 1 (one) for production to keep time-in-order ingestion's otherwise use the number of active kafka-cluster members
      "partitions" = each.value.partitions
      # should be between 1 and 3 replicas
      "replicas" = each.value.replicas
    }
  }
  field_manager {
    name            = "terraform"
    force_conflicts = true  # fix: allows Terraform to override existing field ownership
  }
}
