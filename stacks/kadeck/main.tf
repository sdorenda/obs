resource "kubernetes_namespace" "kadeck" {
  metadata {
    name = "kadeck"
    labels = {
      shared-gateway-access = "true"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cattle.io/status"],
      metadata[0].annotations["lifecycle.cattle.io/create.namespace-auth"],
    ]
  }
}


# kadeck helm chart
# https://artifacthub.io/packages/helm/kadeck/kadeck-teams
# https://gitlab.com/xeotekgit/kadeck-helm/
resource "helm_release" "kadeck" {
  name       = "kadeck"
  repository = "https://dl.cloudsmith.io/public/xeotek-gmbh/kadeck/helm/charts/"
  chart      = "kadeck-teams"
  namespace  = kubernetes_namespace.kadeck.metadata[0].name
  version    = "1.1.10"

  values = [
    yamlencode({
      xeotek = {
        kadeck = {
          teamid = "sandro.manke_ext@50hertz.com"
          secret = "sandro.manke_ext@50hertz.com"
          # TODO: this doesnt allow to reference a secret which is ##### again. we will have to fix this via kustomize
          dbUrl = "jdbc:postgresql://kadeck-db-rw.kadeck:5432/app?password=4Ddq2ezRBlywTXvbwmTpsJElZ9n3uzkfmQ1zFBtQqOweUBavb9vhcl3F2tIgc52V&user=app"
          #dbUsername = ""
          #dbPassword = ""
        }
      }
      ingress = {
        # TODO: should go over our routes as we dont use ingress api, but gateway api
        enabled = false
      }
    })
  ]
}
