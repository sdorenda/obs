resource "kubernetes_namespace" "cnpg" {
  metadata {
    name = "cnpg-system"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cattle.io/status"],
      metadata[0].annotations["lifecycle.cattle.io/create.namespace-auth"],
    ]
  }
}

# https://artifacthub.io/packages/helm/cloudnative-pg/cloudnative-pg
# https://cloudnative-pg.io/documentation/1.25/
resource "helm_release" "cnpg" {
  name       = "cnpg"
  repository = "https://cloudnative-pg.io/charts/"
  chart      = "cloudnative-pg"
  namespace  = kubernetes_namespace.cnpg.metadata[0].name
  version    = var.cnpg_version
  

  values = [
    yamlencode({
      fullnameOverride = "cnpg"
      
    })
  ]
}
