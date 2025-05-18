locals {
  users = {

    # sandbox (testing) user/user-group
    otel-sandbox-rw = {
      topicPrefix = "sbx-"
      group = "sbx-user-group"
      secretRef = "kafka-client-pwd-otel-sbx-default-rw"
    }

    # default open telemetry user/user-group
    otel-default-rw = {
      # @todo: this may be lists later, but lets make it more complex when we need that.
      topicPrefix = "otel-"
      group = "otel-collector"
      secretRef = "kafka-client-pwd-otel-default-rw"
    }

    # networking open telemetry user/user-group
    otel-networking-rw = {
      topicPrefix = "otel-networking-"
      group = "otel-user-group"
      secretRef = "kafka-client-pwd-otel-networking-rw"
    }
  }
}

resource "kubernetes_manifest" "users" {
  for_each = local.users
  manifest = {
    "apiVersion" = "kafka.strimzi.io/v1beta2"
    "kind"       = "KafkaUser"
    "metadata" = {
      "labels" = merge(var.labels,{
        "strimzi.io/cluster" = var.kafka_cluster_name
      })
      "name"      = each.key
      "namespace" = kubernetes_namespace.kafka_cluster.metadata[0].name
    }
    "spec" = {
      "authentication" = {
        "type" = "scram-sha-512"
        "password" = {
          "valueFrom" = {
            "secretKeyRef" = {
              "name" = each.value.secretRef
              "key"  = "client-passwords"
            }
          }
        }
      }
      "authorization" = {
        "acls" = [
          {
            "host" = "*"
            "operations" = [
              "Describe",
            ]
            "resource" = {
              "type" = "cluster"
            }
          },
          {
            "host" = "*"
            "operations" = [
              "Read",
              "Write",
              "Describe",
              "DescribeConfigs",
            ]
            "resource" = {
              "name" = each.value.topicPrefix
              "patternType" = "prefix"
              "type" = "topic"
            }
          },
          {
            "host" = "*"
            "operations" = [
              "Read",
              "Describe",
              "DescribeConfigs",
            ]
            "resource" = {
              "name" = each.value.group
              "patternType" = "literal"
              "type" = "group"
            }
          },
        ]
        "type" = "simple"
      }
    }
  }

  field_manager {
    name            = "terraform"
    force_conflicts = true  # fix: allows Terraform to override existing field ownership
  }
}
