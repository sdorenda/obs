include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}//stacks/grafana"
}

inputs = {
  /*
  name          = "Keycloak-OAuth"
  enable        = true
  allow_sign_up = true

  // https://github.com/grafana/helm-charts/blob/main/charts/grafana/README.md#how-to-securely-reference-secrets-in-grafanaini
  client_id     = "$__file{/etc/secrets/auth_generic_oauth/client_id}"
  client_secret = "$__file{/etc/secrets/auth_generic_oauth/client_secret}"

  scopes               = "openid email profile offline_access roles"
  email_attribute_path = "email"
  login_attribute_path = "username"
  name_attribute_path  = "full_name"
  auth_url             = "https://<PROVIDER_DOMAIN>/realms/<REALM_NAME>/protocol/openid-connect/auth"
  token_url            = "https://<PROVIDER_DOMAIN>/realms/<REALM_NAME>/protocol/openid-connect/token"
  api_url              = "https://<PROVIDER_DOMAIN>/realms/<REALM_NAME>/protocol/openid-connect/userinfo"
  role_attribute_path  = "contains(roles[*], 'admin') && 'Admin' || contains(roles[*], 'editor') && 'Editor' || 'Viewer'"
  */
}
