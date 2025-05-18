locals {
  teams = {
    storage = {
      admins = [
        "mmue",
      ]
      members = [
        "sglo"
      ]
    }
    compute = {
      admins = [
      ]
      members = []
    }
    network = {
      admins = [
        "jstei"
      ]
      members = [
        "sbirt",
        "smau",
        "smoh",
        "ctomi",
        "rstar"
      ]
    }
    observability = {
      admins = [
        "ppae",
        "rwit",
        "sman"
      ]
      members = [
        "jstei"
      ]
    }
    security = {
      admins = [
      ]
      members = []
    }
  }

  users = {
    admin = {
      name          = "Root Admin"
      email         = "admin@localhost"
      grafana_admin = true
      org_role      = "Admin"
    }
    sman = {
      name          = "Sandro Manke"
      email         = "sandro.manke_ext@50hertz.com"
      grafana_admin = false
      org_role      = "Editor"
    }
    rwit = {
      name          = "Robin Wittler"
      email         = "robin.wittler@50hertz.com"
      grafana_admin = false
      org_role      = "Editor"
    }
    ppae = {
      name          = "Patrick Paechnatz"
      email         = "patrick.paechnatz_ext@50hertz.com"
      grafana_admin = false
      org_role      = "Editor"
    }
    sbirt = {
      name          = "Simon Birtles"
      email         = "simon.birtles_ext@50hertz.com"
      grafana_admin = false
      org_role      = "Viewer"
    }
    jstei = {
      name          = "Johannes Steinke"
      email         = "johannes.steinke_ext@50hertz.com"
      grafana_admin = false
      org_role      = "Viewer"
    }
    smau = {
      name          = "Steven Mau"
      email         = "steven.mau_ext@50hertz.com"
      grafana_admin = false
      org_role      = "Viewer"
    }
    smoh = {
      name          = "Sufiyan Shaikh Mohammed"
      email         = "mohammedsufiyan.shaikh_ext@50hertz.com"
      grafana_admin = false
      org_role      = "Viewer"
    }
    ctomi = {
      name          = "Tomislav Cerovski"
      email         = "tomislav.cerovski_ext@50hertz.com"
      grafana_admin = false
      org_role      = "Viewer"
    }
    sglo = {
      name          = "Sascha Glotzbach"
      email         = "sascha.glotzbach_ext@50hertz.com"
      grafana_admin = false
      org_role      = "Viewer"
    }
    mmue = {
      name          = "Michael Muensch"
      email         = "michael.muensch_ext@50hertz.com"
      grafana_admin = false
      org_role      = "Viewer"
    }

    rstar = {
      name          = "Radoslaw Starczewski"
      email         = "radoslaw.starczewski_ext@50hertz.com"
      grafana_admin = false
      org_role      = "Viewer"
    }

  }

}

data "grafana_organization_preferences" "this" {
  org_id = grafana_organization.this.org_id
}


resource "grafana_organization" "this" {
  name         = "Infrastructure"
  admin_user   = "admin"
  create_users = true
  admins = [
    for user in local.users : user.email if user.org_role == "Admin"
  ]
  editors = [
    for user in local.users : user.email if user.org_role == "Editor"
  ]
  viewers = [
    for user in local.users : user.email if user.org_role == "Viewer"
  ]
}
