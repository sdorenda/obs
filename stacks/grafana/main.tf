resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"
    labels = {
      shared-gateway-access = "true"
    }
  }
}


# grafana helm chart
# https://artifacthub.io/packages/helm/grafana/grafana
# https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.grafana.metadata[0].name
  version    = "8.8.3"

  values = [
    yamlencode({
      image = {
        registry = var.docker_repositories.docker_hub
      }

      testFramework = {
        image = {
          registry = var.docker_repositories.docker_hub
        }
      }

      downloadDashboardsImage = {
        registry = var.docker_repositories.docker_hub
      }

      initChownData = {
        image = {
          registry = var.docker_repositories.docker_hub
        }
      }

      sidecar = {
        image = {
          registry = var.docker_repositories.docker_hub
        }
      }

      imageRenderer = {
        image = {
          registry = var.docker_repositories.docker_hub
        }
      }

      persistence = {
        enabled          = true
        type             = "pvc"
        size             = "10Gi"
        storageClassName = "s1-iscsi-ext4-persist"
        accessModes      = ["ReadWriteOnce"]
      }

      # "grafana.ini" = {
      #   server = {
      #     root_url = "https://opsgw.ctn-h.test.pndrs.de:18443"
      #   }
      # }

      /*
      // https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/keycloak/
      auth = {
        generic_oauth = {
          enabled              = var.auth.enabled
          name                 = var.auth.name
          allow_sign_up        = var.auth.allow_sign_up
          client_id            = var.auth.client_id
          client_secret        = var.auth.client_secret
          scopes               = var.auth.scopes
          email_attribute_path = var.auth.email_attribute_path
          login_attribute_path = var.auth.login_attribute_path
          name_attribute_path  = var.auth.name_attribute_path
          auth_url             = var.auth.auth_url
          token_url            = var.auth.token_url
          api_url              = var.auth.api_url
          role_attribute_path  = var.auth.role_attribute_path
        }
      }
      */
    })
  ]
}
