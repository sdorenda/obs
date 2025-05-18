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
    quay_io         = string
    edp_docker      = string
    docker_hub      = string
  })
}

/*
variable "auth" {
  type = object({
    name = string
    enabled = bool
    allow_sign_up = bool
    client_id = string
    client_secret = string
    scopes = string
    email_attribute_path = string
    name_attribute_path = string
    auth_url = string
    token_url = string
    api_url = string
    role_attribute_path = string
  })
}
*/
