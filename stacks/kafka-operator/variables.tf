variable "project" {
  type = string
}

variable "cluster" {
  type = object({
    name     = string
    location = string
  })
}

# should be at least 0.45.0 (to support kafka 3.9.0)
variable "kafka_operator_version" {
  type = string
  default = "0.45.0"
}

variable "kafka_operator_watch_namespaces" {
  type = list(string)
  default = ["kafka-cluster","kafka-cluster-sbx"]
}

variable "docker_repositories" {
  type = object({
    quay_io    = string
    edp_docker = string
    docker_hub = string
    ghcr_io    = string
  })
}

# @todo: this block should be based on given environment (available at version 0.9.7+)
variable "labels" {
  type = map(string)
  default = {
    "app.kubernetes.io/managed-by"    = "internal"
    "app.kubernetes.io/infra-version" = "0.9.5"
    "app.kubernetes.io/part-of"       = "kafka-operator"
    "app.kubernetes.io/instance"      = "poc-stable"
    "observability.branch"            = "poc-dev"
    "observability.customer"          = "internal"
    "availability.zone"               = "az-2"
    "env"                             = "dev"
  }
}