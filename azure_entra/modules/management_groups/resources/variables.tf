variable "management_group_name" {
  description = "O nome desta política, que normalmente é um UUID e pode mudar com o tempo."
  type = string
  default = "example-management-group"
}

variable "scope_management_policy" {
  description = "(Obrigatório) O escopo ao qual esta Política de Gerenciamento de Funções será aplicada. Pode referir-se a um grupo de gestão, a uma subscrição ou a um grupo de recursos. Alterar isso força a criação de um novo recurso."
  type = string
  default = null
}

variable "role_definition_id" {
  description = "(Obrigatório) O ID de definição de função com escopo definido da função à qual esta política será aplicada. Alterar isso força a criação de um novo recurso."
  type = string
  default = null
}

variable "eligible_assignment_rules" {
  type = object({
    expiration_required = optional(bool,false)
    expire_after        = optional(string)
  })
    description = <<EOF
    Um bloco elegíveis_assignment_rules conforme definido abaixo.

    (Opcional) expiration_required - Uma tarefa deve ter uma data de validade. false permite atribuição permanente.
    (Opcional) expire_after - O período máximo de validade de uma atribuição, como duração ISO8601. Valores permitidos: P15D, P30D, P90D, P180D ou P365D.
  EOF
  default = null
}

variable "active_assignment_rules" {
  type = object({
    expiration_required = optional(bool,false)
    expire_after        = optional(string)
    require_justification = optional(bool)
    require_multifactor_authentication = optional(bool)
    require_ticket_info = optional(bool)
  })
  description = <<EOF
    Um bloco active_assignment_rules conforme definido abaixo.

    (Opcional) expiration_required - Uma tarefa deve ter uma data de validade. false permite atribuição permanente.
    (Opcional) expire_after - O período máximo de validade de uma atribuição, como duração ISO8601. Valores permitidos: P15D, P30D, P90D, P180D ou P365D.
    (Opcional) require_justification - É necessária uma justificativa para criar novas atribuições.
    (Opcional) require_multifactor_authentication - A autenticação multifator é necessária para criar novas atribuições.
    (Opcional) require_ticket_info - As informações do ticket são necessárias para criar novas atribuições?
  EOF
  default = null
}

variable "activation_rules" {
  type = object({
    approval_stage = optional(object({
      primary_approver = object({
        object_id = string
        type = string
      })
    }))
    maximum_duration             = optional(string)
    require_approval             = optional(bool, false)
    require_justification        = optional(bool)
    require_multifactor_authentication = optional(bool)
    require_ticket_info = optional(bool)
    required_conditional_access_authentication_context = optional(bool)
  })
  description = <<EOF
    An activation_rules block as defined below..

    (Opcional) approval_stage - Um bloco aprovado_stage conforme definido abaixo.
    (Opcional) maximum_duration - O período máximo de tempo que uma função ativada pode ser válida, em um formato de duração ISO8601 (por exemplo, PT8H). O intervalo válido é PT30M a PT23H30M, em incrementos de 30 minutos, ou PT1D.
    (Opcional) require_approval - A aprovação é necessária para ativação. Se verdadeiro, um bloco de aprovação_stage deverá ser fornecido.
    (Opcional) require_justification - É necessária uma justificativa durante a ativação da função.
    (Opcional) require_multifactor_authentication - A autenticação multifator é necessária para ativar a função. Conflita com require_conditional_access_authentication_context.
    (Opcional) require_ticket_info - As informações do ticket são necessárias durante a ativação da função?
    (Opcional) required_conditional_access_authentication_context - O contexto de acesso condicional do Entra ID que deve estar presente para ativação. Conflita com require_multifactor_authentication.
  EOF
  default = null
}

variable "notification_rules" {
  type = object({
    active_assignments = optional(object({
      admin_notifications = optional(object({
        notification_level = string
        default_recipients = bool
        additional_recipients = optional(list(string))
      }))
        approver_notifications = optional(object({
        notification_level = string
        default_recipients = bool
        additional_recipients = optional(list(string))
      }))
        assignee_notifications = optional(object({
        notification_level = string
        default_recipients = bool
        additional_recipients = optional(list(string))
      }))
    }))
    eligible_activations = optional(object({
      admin_notifications = optional(object({
        notification_level = string
        default_recipients = bool
        additional_recipients = optional(list(string))
      }))
        approver_notifications = optional(object({
        notification_level = string
        default_recipients = bool
        additional_recipients = optional(list(string))
      }))
        assignee_notifications = optional(object({
        notification_level = string
        default_recipients = bool
        additional_recipients = optional(list(string))
      }))
    }))
    eligible_assignments = optional(object({
      admin_notifications = optional(object({
        notification_level = string
        default_recipients = bool
        additional_recipients = optional(list(string))
      }))
        approver_notifications = optional(object({
        notification_level = string
        default_recipients = bool
        additional_recipients = optional(list(string))
      }))
        assignee_notifications = optional(object({
        notification_level = string
        default_recipients = bool
        additional_recipients = optional(list(string))
      }))
    }))
  })
  description = <<EOF
    A notification_rules block supports the following.

    (Opcional) admin_notifications - Um bloco warning_settings conforme definido acima.
    (Opcional) approver_notifications - Um bloco warning_settings conforme definido acima.
    (Opcional) assignee_notifications - Um bloco warning_settings conforme definido acima.
    (Opcional) additional_recipients - Uma lista de endereços de e-mail adicionais que receberão essas notificações.
    (Obrigatório) default_recipients - Caso os destinatários padrão recebam essas notificações.
    (Obrigatório) notification_level -  Qual nível de notificações deve ser enviado. As opções são Todas ou Críticas.
  EOF
  default = null
}