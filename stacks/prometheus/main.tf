resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

# prometheus helm chart
# https://artifacthub.io/packages/helm/prometheus-community/prometheus
# https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace.prometheus.metadata[0].name
  version    = "25.30.0"

  values = [
    yamlencode({
      kube-state-metrics = {
        # https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-state-metrics/values.yaml
        enabled = false
      }

      prometheus-node-exporter = {
        # https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter
        enabled = false
        image = {
          registry = var.docker_repositories.quay_io
        }
      }

      prometheus-pushgateway = {
        # https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-pushgateway
        enabled = true
        image = {
          repository = "${var.docker_repositories.quay_io}/prometheus/pushgateway"
        }
      }

      alertmanager = {
        # https://github.com/prometheus-community/helm-charts/tree/main/charts/alertmanager
        enabled = true
        persistence = {
          enabled      = true
          storageClass = "s1-iscsi-ext4-persist"
          size         = "500Mi"
        }
        image = {
          repository = "${var.docker_repositories.quay_io}/prometheus/alertmanager"
        }
      }

      configmapReload = {
        prometheus = {
          image = {
            repository = "${var.docker_repositories.quay_io}/prometheus-operator/prometheus-config-reloader"
          }
        }
      }


      server = {
        image = {
          repository = "${var.docker_repositories.quay_io}/prometheus/prometheus"
          
          # https://github.com/prometheus/prometheus/releases
          tag = "v3.0.0-rc.1"
        }
        persistentVolume = {
          size         = "5Ti"
          storageClass = "s1-iscsi-ext4-persist"
        }
        #defaultFlagsOverride = [
        #  "--enable-feature=otlp-write-receiver"
        #]
        extraFlags: [
          "web.enable-otlp-receiver",
          "web.enable-lifecycle",
        ]
      }
    })
  ]
}
