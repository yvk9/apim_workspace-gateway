output "id" {
  description = "ARM ID of the standalone workspace gateway."
  value       = azurerm_api_management_standalone_gateway.this.id
}

output "name" {
  description = "Standalone workspace gateway name."
  value       = azurerm_api_management_standalone_gateway.this.name
}

output "connection_ids" {
  description = "Map of configuration connection name to ARM ID."
  value       = { for name, connection in azapi_resource.config_connection : name => connection.id }
}

output "connection_source_ids" {
  description = "Map of configuration connection name to workspace ARM ID returned by Azure."
  value = {
    for name, connection in azapi_resource.config_connection :
    name => try(connection.output.properties.sourceId, null)
  }
}

output "connection_default_hostnames" {
  description = "Map of configuration connection name to the default gateway hostname returned by Azure."
  value = {
    for name, connection in azapi_resource.config_connection :
    name => try(connection.output.properties.defaultHostname, null)
  }
}

output "connection_hostnames" {
  description = "Map of configuration connection name to all gateway hostnames returned by Azure."
  value = {
    for name, connection in azapi_resource.config_connection :
    name => try(connection.output.properties.hostnames, [])
  }
}

output "connection_provisioning_states" {
  description = "Map of configuration connection name to the provisioning state returned by Azure."
  value = {
    for name, connection in azapi_resource.config_connection :
    name => try(connection.output.properties.provisioningState, null)
  }
}
