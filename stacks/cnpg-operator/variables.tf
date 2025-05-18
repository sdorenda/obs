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
    ghcr_io    = string
  })
}

variable "cnpg_version" {
  type = string
  default = "0.23.0"
}