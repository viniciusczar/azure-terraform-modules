variable "create_role_assignment" {
  description = "Gerencia a criação de role assignment"
  type = bool
  default = false
}

variable "create_role_definition" {
  description = "Gerencia a criação de role definition"
  type = bool
  default = false
}

variable "create_pim_active_role_assignment" {
  description = "Gerencia a criação de pim active role assignment"
  type = bool
  default = false
}

variable "create_pim_eligible_role_assignment" {
  description = "Gerencia a criação de pim eligible role assignment"
  type = bool
  default = false
}

variable "role_definition_id" {
  description = "(Opcional) Um UUID/GUID exclusivo que identifica esta função - um será gerado se não for especificado. Alterar isso força a criação de um novo recurso."
  type = string
  default = null
}

variable "name" {
  description = "(Obrigatório) O nome da definição de função."
  type = string
  default = null
}

variable "scope" {
  description = "(Obrigatório) O escopo ao qual a definição de função se aplica, como /subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333, /subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333/resourceGroups/myGroup ou /subscriptions/0b1f6471 -1bf0-4dda-aec3-111122223333/resourceGroups/myGroup/providers/Microsoft.Compute/virtualMachines/myVM. Recomenda-se usar a primeira entrada de assignable_scopes. Alterar isso força a criação de um novo recurso."
  type = string
  default = null
}

variable "role_description" {
  description = "(Opcional) Uma descrição da definição de função."
  type = string
  default = null
}

variable "assignable_scopes" {
  description = "(Opcional) Um ou mais escopos atribuíveis para esta definição de função, como /subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333, /subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333/resourceGroups/myGroup ou /subscriptions/0b1f6471 -1bf0-4dda-aec3-111122223333/resourceGroups/myGroup/providers/Microsoft.Compute/virtualMachines/myVM."
  type = list(string)
  default = null
}

variable "permissions" {
  type = object({
    actions = optional(list(string))
    data_actions = optional(list(string))
    not_actions = optional(list(string))
    not_data_actions = optional(list(string))
  })
  default = null
}

variable "role_assignment" {
  type = list(object({
    name = optional(string)
    description = optional(string)
    scope = string
    role_definition_id = optional(string)
    role_definition_name = optional(string)
    principal_id = string
    principal_type = optional(string)
    condition = optional(string)
    condition_version = optional(string)
    delegated_managed_identity_resource_id = optional(string)
    skip_service_principal_aad_check = optional(string)
  }))
  description = <<EOF
    Crie atribuições de função.

    (Opcional) nome – O nome da zona DNS privada. Deve ser um nome de domínio válido.
    Descrição (opcional) - Descrição desta atribuição de função.
    Escopo (obrigatório) - Escopo ao qual a atribuição de função se aplica.
    (Opcional) role_definition_id - ID do escopo da definição de função.
    (Opcional) role_definition_name – Nome de uma função integrada.
    (Obrigatório) principal_id - ID do principal (usuário, grupo ou principal de serviço) ao qual atribuir a definição de função.
    (Opcional) principal_type - Tipo de principal_id. Os valores possíveis são `User`, `Group` e `ServicePrincipal`.
    Condição (opcional) – Condição que limita os recursos aos quais a função pode ser atribuída.
    (Opcional) condition_version – Versão da condição
    (Opcional) delegado_gerido_identity_resource_id – ID de recurso delegado do Azure que contém uma identidade gerenciada.
    (Opcional) skip_service_principal_aad_check |
    Se o principal_id for um Diretor de Serviço recentemente provisionado, defina esse valor como true para ignorar a verificação do Azure Active Directory, que pode falhar devido ao atraso de replicação. Este argumento só é válido se principal_id for uma entidade de serviço.
  EOF
  default = []
}

variable "scope_pim_active_role" {
  description = "(Obrigatório) O âmbito desta atribuição de função ativa deve ser um ID de recurso válido. Alterar isso força a criação de um novo recurso."
  type = string
  default = null
}

variable "pim_active_role_definition" {
  description = "(Obrigatório) O ID de definição de função para esta atribuição de função ativa. Alterar isso força a criação de um novo recurso."
  type = string
  default = null
}

variable "active_principal_id" {
  description = "(Obrigatório) ID do objeto da entidade de segurança para esta atribuição de função ativa. Alterar isso força a criação de um novo recurso."
  type        = string
  default     = null
}

variable "active_justification" {
  description = "(Opcional) A justificativa da atribuição de função. Alterar isso força a criação de um novo recurso."
  type        = string
  default     = null
}

variable "time_static" {
  description = "(Opcional) A data/hora de início da atribuição de função. Alterar isso força a criação de um novo recurso."
  type        = string
  default     = null
}


variable "schedule_active_role" {
    description =  <<EOF
    (Opcional) Um bloco de agendamento conforme definido abaixo. Alterar isso força a criação de um novo recurso.

    (Opcional) expiration - Um bloco de expiração conforme definido acima.
    (Opcional) start_date_time – A data/hora de início da atribuição de função. Alterar isso força a criação de um novo recurso.
    EOF
    type = object({
      expiration = optional(object({
        duration_days = optional(number)
        duration_hours = optional(number)
        end_date_time = optional(string)
      }))
      start_date_time = optional(string)
    })
    default = null
}

variable "ticket_active_role" {
    description =  <<EOF
    Um ticketbloco suporta o seguinte:
    number- (Opcional) Número de ticket fornecido pelo usuário a ser incluído com a solicitação. Alterar isso força a criação de um novo recurso.
    system- (Opcional) Nome do sistema de ticket fornecido pelo usuário a ser incluído com a solicitação. Alterar isso força a criação de um novo recurso.
    EOF
    type = object({
        number = optional(string)
        system = optional(string)
    })
    default = null
}

variable "scope_pim_eligible_role" {
  description = "(Obrigatório) O âmbito desta atribuição de função elegível deve ser um ID de recurso válido. Alterar isso força a criação de um novo recurso."
  type = string
  default = null
}

variable "pim_eligible_role_definition" {
  description = "(Obrigatório) O ID de definição de função para esta atribuição de função elegível. Alterar isso força a criação de um novo recurso."
  type = string
  default = null
}

variable "eligible_principal_id" {
  description = "(Obrigatório) ID do objeto da entidade de segurança para esta atribuição de função elegível. Alterar isso força a criação de um novo recurso."
  type        = string
  default     = null
}

variable "eligible_justification" {
  description = "(Opcional) A justificativa da atribuição de função. Alterar isso força a criação de um novo recurso."
  type        = string
  default     = null
}

variable "schedule_eligible_role" {
    description =  <<EOF
    Um bloco de agendamento conforme definido abaixo. Alterar isso força a criação de um novo recurso.

    (Opcional) expiration - Um bloco de expiração conforme definido acima.
    (Opcional) start_date_time – A data/hora de início da atribuição de função. Alterar isso força a criação de um novo recurso.
    EOF
    type = object({
      expiration = optional(object({
        duration_days = optional(number)
        duration_hours = optional(number)
        end_date_time = optional(string)
      }))
      start_date_time = optional(string)
    })
    default = null
}

variable "ticket_eligible_role" {
    description =  <<EOF
    Um ticketbloco suporta o seguinte:
    (Opcional) number - Número de ticket fornecido pelo usuário a ser incluído com a solicitação. Alterar isso força a criação de um novo recurso.
    (Opcional) system - Nome do sistema de ticket fornecido pelo usuário a ser incluído com a solicitação. Alterar isso força a criação de um novo recurso.
    EOF
    type = object({
        number = optional(number)
        system = optional(string)
    })
    default = null
}