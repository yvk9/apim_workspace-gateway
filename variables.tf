variable "name" {
  description = "Standalone workspace gateway name."
  type        = string

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 45 && can(regex("^[A-Za-z](?:[A-Za-z0-9-]*[A-Za-z0-9])?$", var.name))
    error_message = "name must be 1-45 characters, start with a letter, and end with a letter or number."
  }
}

variable "resource_group_name" {
  description = "Resource group containing the standalone workspace gateway."
  type        = string

  validation {
    condition     = length(trimspace(var.resource_group_name)) >= 1 && length(var.resource_group_name) <= 90
    error_message = "resource_group_name must be 1-90 characters."
  }
}

variable "location" {
  description = "Azure region for the gateway. It must match the parent APIM service region."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location cannot be empty."
  }
}

variable "network_mode" {
  description = "Gateway network mode: Internal for private inbound and outbound, or External for public inbound and private outbound."
  type        = string
  default     = "Internal"

  validation {
    condition     = contains(["Internal", "External"], var.network_mode)
    error_message = "network_mode must be Internal or External."
  }
}

variable "backend_subnet_id" {
  description = "ARM ID of the dedicated subnet used by this workspace gateway."
  type        = string

  validation {
    condition     = can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.backend_subnet_id))
    error_message = "backend_subnet_id must be a virtual network subnet ARM ID."
  }
}

variable "capacity" {
  description = "Number of WorkspaceGatewayPremium units."
  type        = number
  default     = 1

  validation {
    condition     = var.capacity >= 1 && var.capacity <= 12 && floor(var.capacity) == var.capacity
    error_message = "capacity must be a whole number from 1 through 12."
  }
}

variable "connections" {
  description = "Map of configuration connection name to APIM workspace ARM ID."
  type        = map(string)

  validation {
    condition     = length(var.connections) >= 1 && length(var.connections) <= 30
    error_message = "connections must contain 1-30 workspaces."
  }

  validation {
    condition = alltrue([
      for name in keys(var.connections) :
      length(name) >= 1 && length(name) <= 30 && can(regex("^[A-Za-z](?:[A-Za-z0-9-]*[A-Za-z0-9])?$", name))
    ])
    error_message = "each connection name must be 1-30 characters, start with a letter, and end with a letter or number."
  }

  validation {
    condition = alltrue([
      for workspace_id in values(var.connections) :
      can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Microsoft\\.ApiManagement/service/[^/]+/workspaces/[^/]+$", workspace_id))
    ])
    error_message = "each connection value must be an APIM workspace ARM ID."
  }

  validation {
    condition = try(length(distinct([
      for workspace_id in values(var.connections) :
      lower(regex("(?i)^(.+)/workspaces/[^/]+$", workspace_id)[0])
    ])) == 1, false)
    error_message = "all connected workspaces must belong to the same APIM service."
  }

  validation {
    condition = try(alltrue([
      for workspace_id in values(var.connections) :
      lower(regex("(?i)^/subscriptions/([^/]+)/", workspace_id)[0]) == lower(regex("(?i)^/subscriptions/([^/]+)/", var.backend_subnet_id)[0])
    ]), false)
    error_message = "each workspace and backend_subnet_id must use the same Azure subscription."
  }
}

variable "timeouts" {
  description = "Timeouts for gateway and configuration-connection operations."
  type = object({
    create = optional(string, "4h")
    read   = optional(string, "10m")
    update = optional(string, "4h")
    delete = optional(string, "2h")
  })
  default = {}

  validation {
    condition = alltrue([
      for value in [var.timeouts.create, var.timeouts.read, var.timeouts.update, var.timeouts.delete] :
      can(regex("^[1-9][0-9]*(s|m|h)$", value))
    ])
    error_message = "timeouts must be positive whole-second, minute, or hour durations such as 30m or 4h."
  }
}

variable "tags" {
  description = "Tags applied to the standalone workspace gateway."
  type        = map(string)
  default     = {}
}
