variable "project" {
  type = string
}

variable "cluster" {
  type = object({
    name     = string
    location = string
  })
}

# should be at least 23.1.2
variable "registry_version" {
  type = string
  default = "23.1.3"
}

# should be the same namespace as kafka is deployed in (!)
variable "registry_namespace" {
  type = string
  default = "kafka-cluster"
}

variable "registry_kafka_sasl_mechanism" {
  type = string
  default = "SCRAM-SHA-512"
}

variable "registry_memory_request" {
  type = string
  default = "512Mi"
}

variable "registry_cpu_request" {
  type = string
  default = "0.250"
}

variable "registry_memory_limit" {
  type = string
  default = "2048Mi"
}

variable "registry_cpu_limit" {
  type = string
  default = "4.250"
}

variable "registry_kafka_bootstrap_svc" {
  type = string
  default = "otel-kafka-bootstrap"
}

variable "registry_kafka_auth_user" {
  type = string
  default = "kafka-cluster-primary-root"
}

variable "registry_kafka_auth_method" {
  type = string
  default = "sasl"
}

variable "registry_kafka_auth_strategy" {
  type = string
  default = "SASL_PLAINTEXT"
}

# not a copy paste error, strimzi secret-name is same as user-name
variable "registry_kafka_auth_secret" {
  type = string
  default = "kafka-cluster-primary-root"
}

variable "registry_kafka_bootstrap_port" {
  type = string
  default = "9094"
}

variable "registry_storage_class" {
  type = string
  default = "s1-iscsi-xfs-persist"
}

variable "registry_replicas" {
  type = number
  default = 2
}

variable "registry_debug" {
  type = bool
  default = true
}

variable "docker_repositories" {
  type = object({
    quay_io    = string
    edp_docker = string
    docker_hub = string
    ghcr_io    = string
  })
}

# will/should be override by corresponding terragrunt.hcl (config) file
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