
# resource "kubernetes_manifest" "grafana_http_route" {
#   manifest = {
#     apiVersion = "gateway.networking.k8s.io/v1"
#     kind       = "HTTPRoute"
#     metadata = {
#       name      = "grafana"
#       namespace = kubernetes_namespace.grafana.metadata.0.name
#     }
#     spec = {
#       parentRefs = [
#         # {
#         #   name      = "otel"
#         #   namespace = "otel-collector"
#         #   sectionName= "web"
#         # },
#         {
#           name      = "otel"
#           namespace = "otel-collector"
#           sectionName= "websecure"
#         }
#       ]
#       hostnames = [
#         "gw.observability.test.pndrs.de"
#       ]
#       rules = [
#         {
#           matches = [
#             {
#               path = {
#                 type = "PathPrefix"
#                 value = "/"
#               }

#             }
#           ]
#           backendRefs = [
#             {
#               name = "grafana"
#               namespace = kubernetes_namespace.grafana.metadata.0.name
#               port = 80
#             }
#           ]
#         }
#       ]
#     }
#   }
  
# }