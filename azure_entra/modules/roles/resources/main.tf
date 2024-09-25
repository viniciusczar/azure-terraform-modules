resource "azurerm_role_definition" "role" {
  count = var.create_role_definition ? 1 : 0

  name = var.name
  role_definition_id = var.role_definition_id
  description = var.role_description

  assignable_scopes = var.assignable_scopes
  scope = var.scope

  dynamic "permissions" {
    for_each = var.permissions != null ? [1] : []
    content {
      actions = can(permissions.value["actions"]) ? permissions.value["actions"] : null
      data_actions = can(permissions.value["data_actions"]) ? permissions.value["data_actions"] : null
      not_actions = can(permissions.value["not_actions"]) ? permissions.value["not_actions"] : null
      not_data_actions = can(permissions.value["not_data_actions"]) ? permissions.value["not_data_actions"] : null
    }
  }
}

resource "azurerm_role_assignment" "default" {
  count              = var.create_role_assignment && length(var.role_assignment) > 0 ? length(var.role_assignment) : 0
  name               = lookup(var.role_assignment[count.index], "name", null)
  description        = lookup(var.role_assignment[count.index], "description", "Role Assignment")
  scope              = var.role_assignment[count.index]["scope"]
  principal_id       = var.role_assignment[count.index]["principal_id"]
  principal_type     = lookup(var.role_assignment[count.index], "principal_type", "ServicePrincipal")
  role_definition_id = lookup(var.role_assignment[count.index], "role_definition_name", null) == null ? var.role_assignment[count.index]["role_definition_id"] : null
  role_definition_name = lookup(var.role_assignment[count.index], "role_definition_id", null) == null ? var.role_assignment[count.index]["role_definition_name"] : null
  condition = lookup(var.role_assignment[count.index], "condition", null)
  condition_version = lookup(var.role_assignment[count.index], "condition_version", null)
  delegated_managed_identity_resource_id = lookup(var.role_assignment[count.index], "delegated_managed_identity_resource_id", null)
  skip_service_principal_aad_check = lookup(var.role_assignment[count.index], "skip_service_principal_aad_check", null)

  lifecycle {
    ignore_changes = [principal_id]
  }
}

resource "azurerm_pim_active_role_assignment" "example" {
  count = var.create_pim_active_role_assignment ? 1 : 0
  scope              = var.scope_pim_active_role
  role_definition_id = "${var.scope_pim_active_role}${var.pim_active_role_definition}"
  principal_id       = var.active_principal_id

  justification = var.active_justification

  dynamic "schedule" {
    for_each = var.schedule_active_role != null ? [1] : [0]
    content {
      dynamic "expiration" {
        for_each = var.schedule_active_role.expiration != null ? [1] : [0]
        content {
          duration_days = var.schedule_active_role.expiration.duration_days
          duration_hours = var.schedule_active_role.expiration.duration_hours
          end_date_time = var.schedule_active_role.expiration.end_date_time
        }
      }
      start_date_time = var.schedule_active_role.start_date_time
    }
  }

  dynamic "ticket" {
    for_each = var.ticket_active_role != null ? [1] : [0]
    content {
        number = var.ticket_active_role.number
        system = var.ticket_active_role.system
    }
  }
}

resource "azurerm_pim_eligible_role_assignment" "example" {
  count = var.create_pim_eligible_role_assignment ? 1 : 0
  scope              = var.scope_pim_eligible_role
  role_definition_id = "${var.scope_pim_eligible_role}${var.pim_eligible_role_definition}"
  principal_id       = var.eligible_principal_id

  justification = var.eligible_justification

  dynamic "schedule" {
    for_each = var.schedule_eligible_role != null ? [1] : [0]
    content {
      dynamic "expiration" {
        for_each = var.schedule_eligible_role.expiration != null ? [1] : [0]
        content {
          duration_days = var.schedule_eligible_role.expiration.duration_days
          duration_hours = var.schedule_eligible_role.expiration.duration_hours
          end_date_time = var.schedule_eligible_role.expiration.end_date_time
        }
      }
      start_date_time = var.schedule_eligible_role.start_date_time
    }
  }

  dynamic "ticket" {
    for_each = var.ticket_eligible_role != null ? [1] : [0]
    content {
        number = var.ticket_eligible_role.number
        system = var.ticket_eligible_role.system
    }
  }
}