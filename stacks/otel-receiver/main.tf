resource "kubernetes_namespace" "otel_receiver" {
  metadata {
    name = "otel-receiver"
    annotations = {
      "sidecar.opentelemetry.io/inject" = "true"
    }
  }
}

resource "kubernetes_service_account_v1" "otel_receiver" {
  metadata {
    name      = "otel-collector"
    namespace = kubernetes_namespace.otel_receiver.metadata[0].name
  }
}

resource "kubernetes_config_map_v1" "receiver" {
  metadata {
    name      = "otel-collector-config"
    namespace = kubernetes_namespace.otel_receiver.metadata[0].name
  }

  data = {
    "config.yaml" = var.otel_config_yaml

  }
  depends_on = [kubernetes_namespace.otel_receiver]
}


resource "kubernetes_service_v1" "receiver" {
  metadata {
    name      = "otel-collector"
    namespace = kubernetes_namespace.otel_receiver.metadata[0].name
    labels = {
      app       = "opentelemetry"
      component = "otel-collector"
    }
  }
  spec {
    selector = {
      component = "otel-collector"
    }

    # Default endpoint for querying metrics.
    port {
      port        = 8888
      target_port = 8888
      protocol    = "TCP"
      name        = "metrics"
    }
  }
}

resource "kubernetes_deployment_v1" "receiver" {
  metadata {
    name      = "otel-collector"
    namespace = kubernetes_namespace.otel_receiver.metadata[0].name
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

          # https://opentelemetry.io/docs/collector/distributions/
          image = "${var.docker_repositories.docker_hub}/otel/opentelemetry-collector-contrib:latest"

          # TODO: we will need a custom distro for this for production. https://opentelemetry.io/docs/collector/custom-collector/

          volume_mount {
            name       = "otel-collector-config"
            mount_path = "/etc/otelcol-contrib/config.yaml"
            sub_path   = "config.yaml"
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
            name = "K8S_NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
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
      }
    }
  }
}
