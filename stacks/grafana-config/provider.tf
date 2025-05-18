provider "grafana" {
  url  = "https://gw.observability.test.pndrs.de/"
  auth = var.grafana_auth
}