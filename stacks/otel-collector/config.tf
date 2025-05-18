# output "debug" {
#   value = merge(yamldecode(file("otel-config.yaml")))
# }

locals {
  otel_config = merge(
    yamldecode(file("otel-config.yaml")), 
    #[ for k in try(fileset("otel", "*.yaml"), []) : yamldecode(file("otel/${k}"))]...
  )

  tcpRoutes = {
    syslogtcp = {
      port = 54526
    }
    # otel2grpc = {
    #   port = 14317
    # }
    # otel2http = {
    #   port = 14318
    # }
    syslogtcptls = {
      port     = 54528
      protocol = "TLS"
      tls = {
        mode = "Passthrough"
      }
    }
    syslogtcptlst = {
      port     = 54529
      protocol = "TLS"
      tls = {
        mode = "Terminate"
        certificateRefs = [for s in local.certs : {
          kind = "Secret"
          name = replace(s, ".", "-")
        }]
      }

    }
  }
}


/*

this was temporary snmp config for reference if we happen to need it again
{
        # collection_interval = "60s"
        # timeout             = "5s"
        # endpoint            = v
        # version             = "v2c"
        # community           = "public" 

        # # examples: https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/receiver/snmpreceiver/testdata/config.yaml
        # metrics = {
        #   "ifInOctets!@#.iso.org.dod.internet.mgmt.mib-2.interfaces.ifTable.ifEntry.ifInOctets" = {
        #     unit = "By"
        #     gauge = {
        #       value_type = "int"
        #     }
        #     column_oids = [
        #       {
        #         oid = ".1.3.6.1.2.1.2.2.1.10"
        #       }
        #     ]
        #   }
        # }
      },
      {
        # https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/snmpreceiver
        # for k, v in local.snmp_pull_hosts : "snmp/${k}" => {
        #   collection_interval = "60s"
        #   timeout             = "5s"
        #   endpoint            = v
        #   version             = "v3"
        #   user                = "obs"
        #   security_level      = "auth_priv"
        #   auth_type           = "SHA"
        #   auth_password       = "$${env:SNMP_AUTH_PASSWORD}"
        #   privacy_type        = "AES"
        #   privacy_password    = "$${env:SNMP_PRIVACY_PASSWORD}"

        #   # examples: https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/receiver/snmpreceiver/testdata/config.yaml
        #   metrics = {
        #     "ifInOctets!@#.iso.org.dod.internet.mgmt.mib-2.interfaces.ifTable.ifEntry.ifInOctets" = {
        #       unit = "By"
        #       gauge = {
        #         value_type = "int"
        #       }
        #       column_oids = [
        #         {
        #           oid = ".1.3.6.1.2.1.2.2.1.10"
        #         }
        #       ]
        #     }
        #   }
        # }
      }

*/