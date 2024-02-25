locals {
  location                           = var.location != null ? var.location : data.azurerm_resource_group.rg.location
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"

  secrets = try(jsondecode(azapi_resource.container_app.body).properties.secrets, null) != null ? [
    for secret in jsondecode(azapi_resource.container_app.body).properties.secrets : {
      name                = secret.name
      value               = secret.value
      identity            = secret.identity
      key_vault_secret_id = secret.keyVaultUrl
    }
  ] : null

  templates = {
    revision_suffix = jsondecode(azapi_resource.container_app.body).properties.template.revisionSuffix
    max_replicas    = jsondecode(azapi_resource.container_app.body).properties.template.scale.maxReplicas
    min_replicas    = jsondecode(azapi_resource.container_app.body).properties.template.scale.minReplicas

    init_container = try(jsondecode(azapi_resource.container_app.body).properties.template.initContainers, null) != null ? [
      for ic in jsondecode(azapi_resource.container_app.body).properties.template.initContainers :
      {
        name    = ic.name
        image   = ic.image
        cpu     = ic.resources.cpu
        memory  = ic.resources.memory
        command = ic.command
        args    = ic.args
        env = ic.env != null ? [
          for e in ic.env :
          {
            name        = e.name
            value       = e.value
            secret_name = e.secretRef
          }
        ] : []
        volume_mounts = ic.volumeMounts != null ? [
          for vm in ic.volumeMounts :
          {
            name       = vm.volumeName
            mount_path = vm.mountPath
            sub_path   = vm.subPath
          }
        ] : []
      }
    ] : null

    container = [
      for c in jsondecode(azapi_resource.container_app.body).properties.template.containers :
      {
        name   = c.name
        image  = c.image
        cpu    = c.resources.cpu
        memory = c.resources.memory

        liveness_probe = c.probes != null ? [
          for probe in c.probes : {
            failure_count_threshold          = probe.failureThreshold
            initial_delay                    = probe.initialDelaySeconds
            interval_seconds                 = probe.periodSeconds
            host                             = probe.host
            path                             = probe.path
            port                             = probe.port
            termination_grace_period_seconds = probe.termination_grace_period_seconds
            timeout                          = probe.timeoutSeconds
            transport                        = probe.transport
            header = probe.httpHeaders != null ? [
              for header in probe.httpHeaders : {
                name  = header.name
                value = header.value
              }
            ] : null
          } if try(probe.type == "Liveness", null)
        ] : null

        readiness_probe = c.probes != null ? [
          for probe in c.probes : {
            failure_count_threshold = probe.failureThreshold
            interval_seconds        = probe.periodSeconds
            host                    = probe.host
            path                    = probe.path
            port                    = probe.port
            success_count_threshold = probe.successThreshold
            timeout                 = probe.timeoutSeconds
            transport               = probe.transport
            header = probe.httpHeaders != null ? [
              for header in probe.httpHeaders : {
                name  = header.name
                value = header.value
              }
            ] : null
          } if try(probe.type == "Readiness", null)
        ] : null

        startup_probe = c.probes != null ? [
          for probe in c.probes : {
            failure_count_threshold          = probe.failureThreshold
            interval_seconds                 = probe.periodSeconds
            host                             = probe.host
            path                             = probe.path
            port                             = probe.port
            termination_grace_period_seconds = probe.termination_grace_period_seconds
            timeout                          = probe.timeoutSeconds
            transport                        = probe.transport
            header = probe.httpHeaders != null ? [
              for header in probe.httpHeaders : {
                name  = header.name
                value = header.value
              }
            ] : null
          } if try(probe.type == "Startup", null)
        ] : null

        command = c.command
        args    = c.args
        env = c.env != null ? [
          for e in c.env :
          {
            name        = e.name
            value       = e.value
            secret_name = e.secretRef
          }
        ] : []
        volume_mounts = c.volumeMounts != null ? [
          for vm in c.volumeMounts :
          {
            name       = vm.volumeName
            mount_path = vm.mountPath
            sub_path   = vm.subPath
          }
        ] : []
      }
    ]

    azure_queue_scale_rules = try(jsondecode(azapi_resource.container_app.body).properties.scale.rules, null) != null ? [
      for rule in jsondecode(azapi_resource.container_app.body).properties.scale.rules : {
        name         = rule.name
        queue_name   = try(rule.azureQueue.queueName, null)
        queue_length = try(rule.azureQueue.queueLength, null)
        authentication = [
          for auth in try(rule.azureQueue.auth, []) : {
            secret_name       = auth.secretRef
            trigger_parameter = auth.triggerParameter
          }
        ]
      } if try(rule.azureQueue, null) != null
    ] : null

    custom_scale_rules = try(jsondecode(azapi_resource.container_app.body).properties.scale.rules, null) != null ? [
      for rule in jsondecode(azapi_resource.container_app.body).properties.scale.rules : {
        name             = rule.name
        custom_rule_type = try(rule.custom.metadata.type, null)
        authentication = [
          for auth in try(rule.custom.auth, []) : {
            secret_name       = auth.secretRef
            trigger_parameter = auth.triggerParameter
          }
        ]
      } if try(rule.custom, null) != null
    ] : null

    http_scale_rules = try(jsondecode(azapi_resource.container_app.body).properties.scale.rules, null) != null ? [
      for rule in jsondecode(azapi_resource.container_app.body).properties.scale.rules : {
        name                = rule.name
        concurrent_requests = try(rule.http.metadata.concurrentRequests, null)
        authentication = [
          for auth in try(rule.http.auth, []) : {
            secret_name       = auth.secretRef
            trigger_parameter = auth.triggerParameter
          }
        ]
      } if try(rule.http, null) != null
    ] : null

    tcp_scale_rules = try(jsondecode(azapi_resource.container_app.body).properties.scale.rules, null) != null ? [
      for rule in jsondecode(azapi_resource.container_app.body).properties.scale.rules : {
        name                = rule.name
        concurrent_requests = try(rule.tcp.metadata.concurrentRequests, null)
        authentication = [
          for auth in try(rule.tcp.auth, []) : {
            secret_name       = auth.secretRef
            trigger_parameter = auth.triggerParameter
          }
        ]
      } if try(rule.tcp, null) != null
    ] : null

  }

}
