output "otel_config" {
  value = yamldecode(var.otel_config_yaml)
}