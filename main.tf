resource "azurerm_api_management_standalone_gateway" "this" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  location             = var.location
  virtual_network_type = var.network_mode
  backend_subnet_id    = var.backend_subnet_id

  sku {
    name     = "WorkspaceGatewayPremium"
    capacity = var.capacity
  }

  tags = var.tags

  # Azure Policy adds Resource_Tag after creation. The provider treats any gateway tag
  # change as replacement, so ignore only that policy-owned key.
  lifecycle {
    ignore_changes = [tags["Resource_Tag"]]
  }

  timeouts {
    create = var.timeouts.create
    read   = var.timeouts.read
    update = var.timeouts.update
    delete = var.timeouts.delete
  }
}

resource "azapi_resource" "config_connection" {
  for_each = var.connections

  type      = "Microsoft.ApiManagement/gateways/configConnections@2024-05-01"
  name      = each.key
  parent_id = azurerm_api_management_standalone_gateway.this.id

  body = {
    properties = {
      sourceId = each.value
    }
  }

  response_export_values = [
    "properties.defaultHostname",
    "properties.hostnames",
    "properties.provisioningState",
    "properties.sourceId",
  ]

  timeouts {
    create = var.timeouts.create
    read   = var.timeouts.read
    update = var.timeouts.update
    delete = var.timeouts.delete
  }
}
