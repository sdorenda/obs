resource "kubernetes_manifest" "kafka_cluster" {
  manifest = {
    "apiVersion" = "kafka.strimzi.io/v1beta2"
    "kind"       = "Kafka"
    "metadata" = {
      "annotations" = {
        "strimzi.io/kraft"      = "enabled"
        "strimzi.io/node-pools" = "enabled"
      }
      "labels"    = var.labels
      "name"      = var.kafka_cluster_name
      "namespace" = kubernetes_namespace.kafka_cluster.metadata[0].name
    }
    "spec" = {
      "entityOperator" = {
        "template" = {
          "pod" = {
            "affinity" = {
              "nodeAffinity" = {
                "requiredDuringSchedulingIgnoredDuringExecution" = {
                  "nodeSelectorTerms" = [
                    {
                      "matchExpressions" = [
                        {
                          "key"      = "node-role.kubernetes.io/kafka"
                          "operator" = "In"
                          "values" = [
                            "true",
                          ]
                        },
                      ]
                    },
                  ]
                }
              }
            }
            "metadata" = {
              "labels" = var.labels
            }
          }
        }
        "topicOperator" = {
          "logging" = {
            "loggers" = {
              "rootLogger.level" = var.kafka_topic_operator_log_level
            }
            "type" = "inline"
          }
          "reconciliationIntervalMs" = 240000
          "resources" = {
            "limits" = {
              "cpu"    = "0.450"
              "memory" = "512Mi"
            }
            "requests" = {
              "cpu"    = "0.050"
              "memory" = "256Mi"
            }
          }
        }
        "userOperator" = {
          "logging" = {
            "loggers" = {
              "rootLogger.level" = var.kafka_user_operator_log_level
            }
            "type" = "inline"
          }
          "reconciliationIntervalMs" = 120000
          "resources" = {
            "limits" = {
              "cpu"    = "0.450"
              "memory" = "512Mi"
            }
            "requests" = {
              "cpu"    = "0.050"
              "memory" = "256Mi"
            }
          }
        }
      }
      "kafka" = {
        "authorization" = {
          "superUsers" = [
            "kafka-cluster-primary-root",
          ]
          "type" = "simple"
        }
        "config" = {
          "auto.create.topics.enable"                = false
          "auto.leader.rebalance.enable"             = true
          "compression.type"                         = "producer"
          "default.replication.factor"               = 3
          "delete.topic.enable"                      = true
          "group.initial.rebalance.delay.ms"         = 3000
          "leader.imbalance.check.interval.seconds"  = 300
          "leader.imbalance.per.broker.percentage"   = 0
          "log.cleanup.policy"                       = "compact,delete"
          "log.retention.bytes"                      = -1
          "log.retention.check.interval.ms"          = 300000
          "log.retention.hours"                      = 168
          "log.roll.hours"                           = 72
          "log.segment.bytes"                        = 1073741824
          "log.segment.delete.delay.ms"              = 60000
          "message.max.bytes"                        = 1048576
          "min.insync.replicas"                      = 2
          "num.io.threads"                           = 6
          "num.network.threads"                      = 3
          "num.partitions"                           = 1
          "num.recovery.threads.per.data.dir"        = 1
          "offsets.retention.minutes"                = 7000
          "offsets.topic.num.partitions"             = 50
          "offsets.topic.replication.factor"         = 3
          "queued.max.requests"                      = 500
          "replica.fetch.wait.max.ms"                = 500
          "replica.lag.time.max.ms"                  = 500
          "replica.socket.receive.buffer.bytes"      = 65536
          "socket.request.max.bytes"                 = 104857600
          "transaction.state.log.min.isr"            = 2
          "transaction.state.log.replication.factor" = 3
          "transaction.timeout.ms"                   = 90000
          "unclean.leader.election.enable"           = false
        }
        "jvmOptions" = {
          "-XX" = {
            "ExplicitGCInvokesConcurrent"    = "true"
            "G1HeapRegionSize"               = "16M"
            "InitiatingHeapOccupancyPercent" = "35"
            "MaxGCPauseMillis"               = "20"
            "MaxMetaspaceFreeRatio"          = "80"
            "MetaspaceSize"                  = "96m"
            "MinMetaspaceFreeRatio"          = "50"
            "UseG1GC"                        = "true"
          }
          "-Xms"             = "6g"
          "-Xmx"             = "6g"
          "gcLoggingEnabled" = true
        }
        "listeners" = [
          {
            "authentication" = {
              "type" = "scram-sha-512"
            }
            "name" = "scram"
            "port" = 9094
            "tls"  = false
            "type" = "internal"
          },
          {
            "authentication" = {
              "type" = "scram-sha-512"
            }
            "configuration" = {
              "bootstrap" = {
                "nodePort" = 32100
              }
              "brokers" = [
                {
                  "broker"   = 0
                  "nodePort" = 32000
                },
                {
                  "broker"   = 1
                  "nodePort" = 32001
                },
                {
                  "broker"   = 2
                  "nodePort" = 32002
                },
              ]
            }
            "name" = "external"
            "port" = 9095
            "tls"  = false
            "type" = "nodeport"
          },
        ]
        "logging" = {
          "loggers" = {
            "kafka.root.logger.level" = var.kafka_cluster_log_level
          }
          "type" = "inline"
        }
        "metricsConfig" = {
          "type" = "jmxPrometheusExporter"
          "valueFrom" = {
            "configMapKeyRef" = {
              "key"  = "metrics-config.yml"
              "name" = "kafka-metrics"
            }
          }
        }
        "version" = var.kafka_version
      }
      "kafkaExporter" = {
        "groupRegex" = ".*"
        "topicRegex" = ".*"
      }
    }
  }
  depends_on = [kubernetes_manifest.kafka_node_pool]
}
