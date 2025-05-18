resource "kubernetes_namespace" "otel_collector" {
  metadata {
    name = "otel-collector"
    annotations = {
      "sidecar.opentelemetry.io/inject" = "true"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cattle.io/status"],
      metadata[0].annotations["lifecycle.cattle.io/create.namespace-auth"],
    ]
  }
}

resource "kubernetes_service_account_v1" "otel_collector" {
  metadata {
    name      = "otel-collector"
    namespace = kubernetes_namespace.otel_collector.metadata[0].name
  }
}

resource "kubernetes_config_map_v1" "collector" {
  metadata {
    name      = "otel-collector-config"
    namespace = kubernetes_namespace.otel_collector.metadata[0].name
  }

  data = {
    "config.yaml" = yamlencode(local.otel_config)

  }
  depends_on = [kubernetes_namespace.otel_collector]
}


resource "kubernetes_service_v1" "collector" {
  metadata {
    name      = "otel-collector"
    namespace = kubernetes_namespace.otel_collector.metadata[0].name
    labels = {
      app       = "opentelemetry"
      component = "otel-collector"
    }
  }
  spec {
    selector = {
      component = "otel-collector"
    }

    # Default endpoint for OpenTelemetry gRPC receiver.
    port {
      port        = 4317
      target_port = 4317
      protocol    = "TCP"
      name        = "otel-grpc"
    }

    # Default endpoint for OpenTelemetry HTTP receiver.
    port {
      port        = 4318
      target_port = 4318
      protocol    = "TCP"
      name        = "otel-http"
    }

    # Default endpoint for querying metrics.
    port {
      port        = 8888
      target_port = 8888
      protocol    = "TCP"
      name        = "metrics"
    }

    dynamic "port" {
      for_each = local.tcpRoutes
      content {
        port        = port.value.port
        target_port = port.value.port
        protocol    = "TCP"
        name        = port.key
      }
    }

    port {
      port        = 54527
      target_port = 54527
      protocol    = "UDP"
      name        = "syslogudp"
    }
  }
}

resource "kubernetes_deployment_v1" "collector" {
  metadata {
    name      = "otel-collector"
    namespace = kubernetes_namespace.otel_collector.metadata[0].name
    labels = {
      app       = "opentelemetry"
      component = "otel-collector"
    }
  }

  spec {
    selector {
      match_labels = {
        app       = "opentelemetry"
        component = "otel-collector"
      }
    }
    min_ready_seconds         = 5
    progress_deadline_seconds = 120
    replicas                  = 1 # TODO
    template {
      metadata {
        labels = {
          app       = "opentelemetry"
          component = "otel-collector"
        }
      }
      spec {
        container {
          name = "otel-collector"

          #image = "${local.docker_repositories.docker_hub}/otel/opentelemetry-collector:latest"
          #command = ["/otelcol", "--config=/conf/otel-collector-config.yaml"]

          # https://opentelemetry.io/docs/collector/distributions/
          image = "${var.docker_repositories.docker_hub}/otel/opentelemetry-collector-contrib:latest"

          # TODO: we will need a custom distro for this for production. https://opentelemetry.io/docs/collector/custom-collector/

          volume_mount {
            name       = "otel-collector-config"
            mount_path = "/etc/otelcol-contrib/config.yaml"
            sub_path   = "config.yaml"
            read_only  = true
          }

          volume_mount {
            name       = "secrets"
            mount_path = "/etc/otelcol-contrib/secrets"
            read_only  = true
          }
          resources {
            limits = {
              memory = "2Gi"
            }
            requests = {
              cpu    = "200m"
              memory = "400Mi"
            }
          }
          env {
            name = "MY_POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }
          env {
            name = "KAFKA_USERNAME"
            value_from {
              secret_key_ref {
                name = "kafka-credentials"
                key  = "username"
              }
            }
          }
          env {
            name = "KAFKA_PASSWORD"
            value_from {
              secret_key_ref {
                name = "kafka-credentials"
                key  = "password"
              }
            }
          }
          env {
            name = "SNMP_AUTH_PASSWORD"
            value_from {
              secret_key_ref {
                name = "snmp-credentials"
                key  = "auth-password"
              }
            }
          }
          env {
            name = "SNMP_PRIVACY_PASSWORD"
            value_from {
              secret_key_ref {
                name = "snmp-credentials"
                key  = "privacy-password"
              }
            }
          }
          env {
            name = "K8S_NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          port {
            container_port = 54526
            name           = "syslogtcp"
          }
          port {
            container_port = 54527
            name           = "syslogudp"
            protocol       = "UDP"
          }
          port {
            container_port = 54528
            name           = "syslogtcptls"
          }
          # Default endpoint for ZPages.
          port {
            container_port = 55679
            name           = "zpages"
          }
          # Default endpoint for OpenTelemetry receiver.
          port {
            container_port = 4317
            name           = "otel-grpc"
          }
          # Default endpoint for Jaeger gRPC receiver.
          port {
            container_port = 14250
            name           = "jaeger-grpc"
          }
          # Default endpoint for Jaeger HTTP receiver.
          port {
            container_port = 14268
            name           = "jaeger-http"
          }
          # Default endpoint for Zipkin receiver.
          port {
            container_port = 9411
            name           = "zipkin"
          }
          # Default endpoint for querying metrics.
          port {
            container_port = 8888
            name           = "metrics"
          }
        }
        volume {
          name = "otel-collector-config"
          config_map {
            name = "otel-collector-config"
          }
        }

        volume {
          name = "secrets"
          projected {
            sources {
              dynamic "secret" {
                for_each = local.certs
                content {
                  name = replace(secret.value, ".", "-")
                  items {
                    key  = "tls.crt"
                    path = "${replace(secret.value, ".", "-")}.crt"
                  }
                  items {
                    key  = "tls.key"
                    path = "${replace(secret.value, ".", "-")}.key"
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.certs]
}
