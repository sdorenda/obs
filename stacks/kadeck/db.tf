resource "kubernetes_manifest" "kadeck_pg_cluster" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"
    metadata = {
      name      = "kadeck-db"
      namespace = kubernetes_namespace.kadeck.metadata[0].name
    }
    spec = {
      instances = 1

      storage = {
        storageClass = "s1-iscsi-xfs-persist"
        size = "10Gi"
      }
    }
  }
}
