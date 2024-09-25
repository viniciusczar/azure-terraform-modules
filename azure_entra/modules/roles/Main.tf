data "azurerm_role_definition" "role_definition" {
  role_definition_id = "02000010-4000-0000-0960-000000000011"
  timeouts {
    read = "1m"
  }
}

module "roles" {
  source = "./modules/roles/resources"

  create_role_definition = true
  name = "Readness"
  role_definition_id = "02000010-4000-0000-0960-000000000011"
  role_description = "Inconspicuous role definition"

  assignable_scopes = [data.azurerm_subscription.primary.id]
  scope = data.azurerm_subscription.primary.id

  permissions = {
    actions     = ["Microsoft.Resources/subscriptions/resourceGroups/read"]
    not_actions = []
  }

  create_role_assignment = false
  role_assignment = [
    {
      scope = data.azurerm_subscription.primary.id
      principal_id = "a0ebd575-0aa1-4b66-a1ea-ee339a0cb864"
      role_definition_name = "Reader"
      principal_type = "User"
    },
    {
      scope = data.azurerm_subscription.primary.id
      principal_id = "e9e1ee52-de66-4b64-8241-9dad977a9536"
      role_definition_id = data.azurerm_role_definition.role_definition.id
      principal_type = "Group"
    },
  ]

  # Recurso abaixo somente é permitido para Microsoft Entra P2 ou Microsoft Entra ID Governance license.
    create_pim_active_role_assignment = false
    scope_pim_active_role = data.azurerm_subscription.primary.id
    pim_active_role_definition = "02000010-4000-0000-0960-000000000011"
    active_principal_id = data.azuread_client_config.current.object_id
    active_justification = "This is a test"

    schedule_active_role = {
      start_date_time = time_static.example.rfc3339
      expiration = {
        duration_hours = 8 # Use essa variável quando não estiver usando duration_days ou end_date_time
        #duration_days = 7 # Use essa variável quando não estiver usando duration_hours ou end_date_time
        #end_date_time = "2099-10-02T17:22:00Z" # Use essa variável quando não estiver usando duration_days ou duration_hours
      }
    }

    ticket_active_role = {
      number = "1"
      system = "example ticket system"
    }

  # Recurso abaixo somente é permitido para Microsoft Entra P2 ou Microsoft Entra ID Governance license.
    create_pim_eligible_role_assignment = false
    scope_pim_eligible_role = data.azurerm_subscription.primary.id
    pim_eligible_role_definition = "02000010-4000-0000-0960-000000000011"
    eligible_principal_id = data.azuread_client_config.current.object_id
    eligible_justification = "This is a test"

    schedule_eligible_role = {
      start_date_time = time_static.example.rfc3339
      expiration = {
        #duration_hours = 8 # Use essa variável quando não estiver usando duration_days ou end_date_time
        duration_days = 7 # Use essa variável quando não estiver usando duration_hours ou end_date_time
        #end_date_time = "2099-10-02T17:22:00Z" # Use essa variável quando não estiver usando duration_days ou duration_hours
      }
    }

    ticket_eligible_role = {
      number = "1"
      system = "example ticket system"
    }

    depends_on = [ time_static.example, data.azurerm_role_definition.role_definition ]


}

resource "time_static" "example" {}


