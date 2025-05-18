resource "random_string" "initial_password" {
  for_each = local.users
  length   = 16
}

resource "grafana_user" "this" {
  for_each = local.users
  name     = each.value.name
  email    = each.value.email
  login    = each.key
  is_admin = each.value.grafana_admin
  password = random_string.initial_password[each.key].result
  lifecycle {
    ignore_changes = [password]
  }
}

resource "grafana_team" "this" {
  for_each = local.teams
  name     = each.key
  org_id   = grafana_organization.this.org_id
  members  = [for _, k in concat(each.value.members, each.value.admins) : grafana_user.this[k].email]
}
