# APIM workspace gateway Terraform module

Creates one API Management standalone workspace gateway and its workspace configuration connections.

The caller provides an existing resource group, dedicated gateway subnet, and 1-30 workspace resource IDs from the same APIM service. This module does not create the parent APIM service, workspace, network, DNS, RBAC, monitoring, or API configuration.

## Usage

```hcl
module "payments_dev_workspace_gateway" {
  source = "git::https://azdo.fdcctx.us/EFTPS/Modernization/_git/terraform-azurerm-apim-workspace-gateway?ref=v0.1.0"

  name                = "apim-wsg-payments-dev-usva-dev"
  resource_group_name = "rg-app-o-usva-dev"
  location            = "usgovvirginia"
  network_mode        = "Internal"
  backend_subnet_id   = var.payments_dev_gateway_subnet_id

  connections = {
    payments-dev = var.payments_dev_workspace_id
  }

  tags = var.tags
}
```

## Network requirements

- Use one dedicated subnet per workspace gateway. Do not share it with the parent APIM service, another gateway, or another Azure resource.
- Use a `/27` or larger subnet.
- For `Internal` mode, delegate the subnet to `Microsoft.Web/hostingEnvironments` and apply the required load-balancer, private inbound, Key Vault outbound, and backend access rules.
- For `External` mode, delegate the subnet to `Microsoft.Web/serverFarms` and apply the required Key Vault and backend access rules.
- The subnet must be in the same subscription and Azure region as the parent APIM service.
- Configure the AzureRM and AzAPI providers for that subscription.

The module fixes the SKU to `WorkspaceGatewayPremium` and defaults capacity to one unit. Gateway and configuration-connection operations use four-hour create and update timeouts, a ten-minute read timeout, and a two-hour delete timeout.

Confirm workspace-gateway availability in the target Azure Government region before the first deployment.
