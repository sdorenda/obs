resource "kubernetes_namespace" "syslog_test" {
  metadata {
    name = "syslog-test"
  }
}

resource "kubernetes_config_map_v1" "syslog_test" {
  metadata {
    name      = "syslog-test-config"
    namespace = kubernetes_namespace.syslog_test.metadata[0].name
  }

  data = {
    "rsyslog.conf" = templatefile("${path.module}/rsyslog.conf", {
    })

  }
  depends_on = [kubernetes_namespace.syslog_test]
}

resource "kubernetes_deployment_v1" "syslog_test" {
  metadata {
    name = "syslog-test"
    namespace = kubernetes_namespace.syslog_test.metadata[0].name
    labels = {
      app = "syslog-test"
      component = "syslog-test"
    }
  }
  
  spec {
    selector {
      match_labels = {
        app = "syslog-test"
        component = "syslog-test"
      }
    }
    min_ready_seconds = 5
    progress_deadline_seconds = 120
    replicas = 1
    template {
      metadata {
        labels = {
          app = "syslog-test"
          component = "syslog-test"
        }
      }
      spec {
        container {
          name = "syslog-test"
          
          image = var.image == null ? "${var.docker_repositories.edp_docker}/rsyslog:v1" : var.image

          ## https://syslog-ng.github.io/admin-guide/040_Quick-start_guide/000_Configuring_syslog-ng_on_client_hosts
          # https://hub.docker.com/r/balabit/syslog-ng/
          #image = "${local.docker_repositories.docker_hub}/balabit/syslog-ng:latest"
          #args = ["--no-caps"]
          
          #command= [ "/bin/bash", "-c", "--" ]
          #args= [ "trap : TERM INT; sleep infinity & wait" ]
          resources {
            limits = {
              memory = "2Gi"
            }
            requests = {
              cpu = "200m"
              memory = "400Mi"
            }
          }
          volume_mount {
            name = "config"
            mount_path = "/etc/rsyslog.conf"
            sub_path = "rsyslog.conf"
            read_only = true
          }
          
        }
        volume {
          name = "config"
          config_map {
            name = "syslog-test-config"
            
          }
        }
      }
    }
  }
}