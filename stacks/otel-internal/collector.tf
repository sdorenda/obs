resource "kubernetes_manifest" "collector" {
  manifest = {
    apiVersion = "opentelemetry.io/v1beta1"
    kind       = "OpenTelemetryCollector"
    metadata = {
      name = "internal"
      namespace = "otel-collector"
    }
    spec = {
      mode = "sidecar"
      config = {
        receivers = {
          otlp = {
            protocols = {
              grpc = {}
              http = {}
            }
          }
        }
        processors = {
          batch = {}
        }
        exporters = {
          logging = {
            logLevel = "debug"
          }
        }
        service = {
          pipelines = {
            traces = {
              receivers= ["otlp"]
              processors= ["batch"]
              exporters= ["logging","otlp"]
            }
          }
        }
      }
    }
  }
}
