resource "kubernetes_namespace" "tempo" {
  metadata {
    name = "tempo"
  }
}


# https://grafana.com/docs/tempo/latest/setup/helm-chart/
# https://github.com/grafana/helm-charts/tree/main/charts/tempo
# https://github.com/grafana/helm-charts/blob/main/charts/tempo/values.yaml
# https://artifacthub.io/packages/helm/grafana/tempo
resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  namespace  = kubernetes_namespace.tempo.metadata[0].name
  version    = "1.14.0"

  values = [
    yamlencode({
      
      tempo = {
        repository = "${var.docker_repositories.docker_hub}/grafana/tempo"
        reportingEnabled = false
        storage = {
          trace = {
            # TODO: should be s3 too eventually

          }
        }
      }

      tempoQuery = {
        repository = "${var.docker_repositories.docker_hub}/grafana/tempo-query"
      }

      persistence = {
        enabled = true
        storageClassName = "s1-iscsi-ext4-persist"
        size = "5Gi"
      }
    })
  ]
}
