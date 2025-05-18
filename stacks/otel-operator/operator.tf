resource "kubernetes_namespace" "otel_operator" {
  metadata {
    name = "otel-operator"
  }
}

# https://artifacthub.io/packages/helm/opentelemetry-helm/opentelemetry-operator
# https://opentelemetry.io/docs/kubernetes/helm/operator/
# https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-operator/values.yaml
resource "helm_release" "otel_operator" {
  name       = "otel-operator"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-operator"
  namespace  = kubernetes_namespace.otel_operator.metadata[0].name
  version    = "0.73.0"

  values = [
    yamlencode({
      kubeRBACProxy = {
        image = {
          repository= "${var.docker_repositories.quay_io}/brancz/kube-rbac-proxy"
        }
      }
      manager = {
        collectorImage = {
          repository = "${var.docker_repositories.docker_hub}/otel/opentelemetry-collector-k8s",
        },
        image = {
          repository = "${var.docker_repositories.ghcr_io}/open-telemetry/opentelemetry-operator/opentelemetry-operator",
        }
      }
      admissionWebhooks = {
        certManager = {
          enabled = false
          # if we use our own dns here someday. for now its not necessary as its cluster-internal
          # issuerRef = {
          #   kind = "ClusterIssuer"
          #   name = "edp-internal"
          # }
        }
        autoGenerateCert = {
          enabled = true
        }
      }
    })
  ]
}
