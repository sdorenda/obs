variable "project" {
  type = string
}

variable "cluster" {
  type = object({
    name     = string
    location = string
  })
}

variable "docker_repositories" {
  type = object({
    quay_io    = string
    edp_docker = string
    docker_hub = string
  })
}

variable "kafka_replicas" {
  type = number
  default = 3
}

variable "kafka_res_limit_memory" {
  type = string
  default = "10Gi"
}

variable "kafka_res_limit_cpus" {
  type = string
  default = "2.750"
}

# should be at least 3.9.0 (<=3.8.9 is supported as well)
variable "kafka_version" {
  type = string
  default = "3.9.0"
}

# 5 TB should be enough vor everyone ;)
variable "kafka_jbod_storage" {
  type = string
  default = "5T"
}

# should be "s1-iscsi-xfs-persist" in production (after poc)
variable "kafka_jbod_storage_class" {
  type = string
  default = "s1-iscsi-xfs-persist"
}

# should be false in production (after poc)
variable "kafka_jbod_storage_delete_claim" {
  type = bool
  default = false
}

# should be "INFO" in production (after poc)
variable "kafka_cluster_log_level" {
  type = string
  default = "INFO"
}

# should be "INFO" in production (after poc)
variable "kafka_topic_operator_log_level" {
  type = string
  default = "INFO"
}

# should be "INFO" in production (after poc)
variable "kafka_user_operator_log_level" {
  type = string
  default = "INFO"
}

variable "kafka_cluster_name" {
  type = string
  default = "otel"
}

variable "labels" {
  type = map(string)
  default = {
    "app.kubernetes.io/managed-by"    = "internal"
    "app.kubernetes.io/infra-version" = "0.9.5"
    "app.kubernetes.io/part-of"       = "kafka-cluster"
    "app.kubernetes.io/instance"      = "poc-stable"
    "observability.branch"            = "poc-test"
    "observability.customer"          = "internal"
    "availability.zone"               = "az-2"
    "availability.region"             = "eu-de-1"
    "env"                             = "test"
  }
}

variable "kafka_node_labels" {
  description = "Map of labels to be applied to all Kafka nodes"
  type        = map(string)

  default = {
    "node-role.kubernetes.io/kafka" = "true"
    "topology.kubernetes.io/region" = "eu-de-1"
    "topology.kubernetes.io/zone"   = "az-2"
    "kafka.priority"                = "high"
  }
}

variable "kafka_nodes" {
  description = "List of Kafka node names in the Kubernetes cluster"
  type        = list(string)

  default = [
    "c1w6.observability.test.pndrs.de",
    "c1w7.observability.test.pndrs.de",
    "c1w8.observability.test.pndrs.de"
  ]
}

variable "kafka_users" {
  type = map(object({
    password  = string
  }))

  default = {}
}

