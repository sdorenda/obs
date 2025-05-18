resource "kubernetes_namespace" "loki" {
  metadata {
    name = "loki"
  }
}


# https://grafana.com/docs/loki/latest/setup/install/helm/
# There are multiple ways to set up loki. 
# The scalable variant is likely interesting later, but a bit overkill for testing things as we don't even know for sure if we are going to use loki.

# I will go with monolithic initially as it just stores things in the filesystem for now.

# https://github.com/grafana/loki/tree/main/production/helm/loki
# https://github.com/grafana/loki/blob/main/production/helm/loki/values.yaml
# https://artifacthub.io/packages/helm/grafana/loki
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = kubernetes_namespace.loki.metadata[0].name
  version    = "6.24.0"

  values = [
    yamlencode({
      deploymentMode = "SingleBinary",
      global = {
        dnsService = "rke2-coredns-rke2-coredns"
      }
      loki = {
        auth_enabled = false

        image = {
          registry = var.docker_repositories.docker_hub
        }
        commonConfig = {
          replication_factor = 1
        }

        analytics = {
          reporting_enabled = false
        }

        limitsConfig = {
          reject_old_samples = false
          #reject_old_samples_max_age: 168h
        }

        storage = {
          type = "s3"

          bucketNames = {
            chunks = "grafana-loki"
            ruler  = "grafana-loki"
            admin  = "grafana-loki"
          }
          s3 = {
            # Node 01 100.124.182.45
            # Node 02 100.124.182.46
            endpoint         = "https://100.124.182.45"
            secretAccessKey  = var.s3_secret_access_key
            accessKeyId      = var.s3_access_key_id
            s3ForcePathStyle  = true
            insecure          = true
            region            = null
            sse_encryption    = false
            disable_dualstack = true
            http_config = {
              idle_conn_timeout       = "90s"
              response_header_timeout = "0s"
              insecure_skip_verify    = true
            }
          }

          # # minio storage

          # bucketNames = {
          #   chunks = "chunks"
          #   ruler  = "ruler"
          #   admin  = "admin"
          # }
          # s3 = {
          #   s3                = "http://enterprise-logs:supersecret@loki-minio.default.svc.cluster.local:9000"
          #   endpoint          = "http://loki-minio.default.svc.cluster.local:9000"
          #   s3ForcePathStyle  = true
          #   access_key_id     = "enterprise-logs"
          #   secret_access_key = "supersecret"
          #   insecure          = true
          #   region            = null
          #   sse_encryption    = false
          #   http_config = {
          #     idle_conn_timeout       = "90s"
          #     response_header_timeout = "0s"
          #     insecure_skip_verify    = true
          #   }
          # }
        }
        # https://grafana.com/docs/loki/latest/configuration/#schema_config
        schemaConfig = {
          configs = [
            # old
            # {
            #   from  = "2024-01-01"
            #   store = "tsdb"
            #   index = {
            #     prefix = "loki_index_"
            #     period = "24h"
            #   }
            #   object_store = "filesystem" # we're storing on filesystem so there's no real persistence here.
            #   schema : "v13"
            # }

            {
              from         = "2024-01-01"
              store        = "tsdb"
              object_store = "s3"
              schema       = "v13"
              index = {
                prefix = "index_"
                period = "24h"
              }
            }
          ]
        }
      }

      test = {
        image = {
          registry = var.docker_repositories.docker_hub
        }
      }
      lokiCanary = {
        image = {
          registry = var.docker_repositories.docker_hub
        }
      }

      gateway = {
        image = {
          registry = var.docker_repositories.docker_hub
        }
        nginxConfig = {
          enableIPv6 = false
          resolver   = "rke2-coredns-rke2-coredns.kube-system.svc.cluster.local."
        }
      }

      # https://github.com/minio/minio/blob/master/helm/minio/values.yaml
      minio = {
        enabled       = false
        replicas      = 2
        drivesPerNode = 2
        persistence = {
          enabled      = true
          storageClass = "s1-iscsi-ext4-persist"
          size         = "1Ti"
          accessMode   = "ReadWriteOnce"
        }
        image = {
          repository = "${var.docker_repositories.quay_io}/minio/minio"
        }
        mcImage = {
          repository = "${var.docker_repositories.quay_io}/minio/mc"
        }

      }

      chunksCache = {

      }

      memcached = {
        image = {
          repository = "${var.docker_repositories.docker_hub}/memcached"
        }
      }

      memcachedExporter = {
        image = {
          repository = "${var.docker_repositories.docker_hub}/prom/memcached-exporter"
        }
      }

      singleBinary = {
        replicas = 1
        persistence = {
          enabled      = true
          storageClass = "s1-iscsi-ext4-persist"
        }
      }
      read = {
        replicas = 0
      }
      backend = {
        replicas = 0
      }
      write = {
        replicas = 0
      }

      sidecar = {
        image = {
          repository = "${var.docker_repositories.docker_hub}/kiwigrid/k8s-sidecar"
        }
      }
    })
  ]
}
