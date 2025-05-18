
resource "kubernetes_namespace" "kafka_schema_registry" {
  count = local.namespace_exists ? 0 : 1

metadata {
    name = var.registry_namespace
    labels = var.labels
  }
}

#
# @links: https://artifacthub.io/packages/helm/bitnami/schema-registry
#
resource "helm_release" "kafka_schema_registry" {
  name       = "kafka-registry"
  repository = "oci://europe-west3-docker.pkg.dev/nz-mgmt-shared-artifacts-8c85/docker-hub/bitnamicharts"
  chart      = "schema-registry"
  namespace  = local.namespace_exists ? var.registry_namespace : kubernetes_namespace.kafka_schema_registry[0].metadata[0].name
  version    = var.registry_version

  values = [
    yamlencode({
      commonLabels = var.labels

      # deactivate internal kafka of schema registry
      kafka = {
        enabled = false
      }

      externalKafka = {
        brokers = "${var.registry_kafka_auth_strategy}://${var.registry_kafka_bootstrap_svc}.${var.registry_namespace}.svc.cluster.local:${var.registry_kafka_bootstrap_port}"

        listener = {
          protocol = var.registry_kafka_auth_strategy
        }

        sasl = {
          user           = var.registry_kafka_auth_user
          existingSecret = var.registry_kafka_auth_secret
        }
      }

      auth = {
        kafka = {
          saslMechanism = var.registry_kafka_sasl_mechanism
        }
      }

      global = {
        defaultStorageClass = var.registry_storage_class
        security = {
          allowInsecureImages = true
        }
      }

      image = {
        debug      = var.registry_debug
        registry   = "${var.docker_repositories.docker_hub}/bitnami"
        repository = "schema-registry"
      }

      nodeAffinityPreset = {
        key   = "node-role.kubernetes.io/kafka"
        value = "true"
      }

      replicaCount = var.registry_replicas

      resources = {
        requests = {
          memory = var.registry_memory_request
          cpu    = var.registry_cpu_request
        }
        limits = {
          memory = var.registry_memory_limit
          cpu    = var.registry_cpu_limit
        }
      }
    })
  ]
}

#
# Data majic
# --

data "kubernetes_namespace" "existing_namespace" {
  metadata {
    name = var.registry_namespace
  }
}

#
# Locals
# --
locals {
  namespace_exists = length(try(data.kubernetes_namespace.existing_namespace.metadata, [])) > 0
}