# Recurso abaixo somente é permitido para Microsoft Entra P2 ou Microsoft Entra ID Governance license.

module "management_group" {
  source = "./modules/management_groups/resources"
  management_group_name = "example-management-group"

  scope_management_policy = data.azurerm_subscription.primary.id
  role_definition_id = data.azurerm_role_definition.builtin.id

  eligible_assignment_rules = {
    expiration_required = false
    expire_after = "P90D"
  }

  active_assignment_rules = {
    expiration_required = false
    expire_after = "P90D"
    require_justification = false
    require_multifactor_authentication = false
    require_ticket_info = true
  }

  activation_rules = {
    maximum_duration = false
    require_approval = true
    require_justification = false
    require_multifactor_authentication = false
    require_ticket_info = true
    required_conditional_access_authentication_context = true
    approval_stage = {
      primary_approver = {
        object_id = data.azuread_group.grp.object_id
        type      = "Group"
      }
    }
  }
  notification_rules = {
    active_assignments = {
      admin_notifications = {
        notification_level    = "Critical"
        default_recipients    = false
        additional_recipients = ["someone@example.com"]
      }
    }
  }


}

data "azuread_group" "grp" {
  display_name     = "Grupo1"
  security_enabled = true
}

data "azurerm_role_definition" "builtin" {
  name = "Contributor"
}