variable "tenant_id" {
  description = "Tenant ID"
  type        = string
  default     = null
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
  default     = null
}

variable "groups" {
  type = list(object({
    display_name = string
    security_enabled = optional(bool)
    administrative_unit_ids = optional(list(string))
    auto_subscribe_new_members = optional(bool)
    assignable_to_role = optional(bool)
    behaviors = optional(list(string))
    description = optional(string)
    external_senders_allowed = optional(bool)
    hide_from_outlook_clients =optional(bool)
    hide_from_address_lists = optional(bool)
    mail_enabled = optional(bool)
    mail_nickname = optional(string)
    mail_group_nickname = optional(string)
    onpremises_group_type = optional(string)
    prevent_duplicate_names = optional(string)
    theme = optional(string)
    visibility = optional(string)
    writeback_enabled = optional(bool)
    types = optional(list(string))
    members = optional(list(string))
    provisioning_options = optional(list(string))
    owners = optional(list(string))
    dynamic_membership = optional(object({
      enabled = bool
      rule = string
    }))
  }))
  default = []
  description = <<EOF
    administrative_unit_ids- (Opcional) Os IDs de objeto das unidades administrativas nas quais o grupo é membro. Se especificado, novos grupos serão criados no escopo da primeira unidade administrativa e adicionados aos outros. Se vazio, novos grupos serão criados no nível do locatário.
    assignable_to_role- (Opcional) Indica se este grupo pode ser atribuído a uma função do Azure Active Directory. O padrão é false. Só pode ser definido como truepara grupos com segurança habilitada. Alterar isso força a criação de um novo recurso.
    auto_subscribe_new_members- (Opcional) Indica se novos membros adicionados ao grupo serão inscritos automaticamente para receber notificações por e-mail. Só pode ser definido para grupos Unificados.
    behaviors- (Opcional) Um conjunto de comportamentos para um grupo do Microsoft 365. Os valores possíveis são AllowOnlyMembersToPost, HideGroupInOutlook, SkipExchangeInstantOn, SubscribeMembersToCalendarEventsDisabled, SubscribeNewGroupMemberse WelcomeEmailDisabled. Veja a documentação oficial para mais detalhes. Alterar isso força a criação de um novo recurso.
    description- (Opcional) A descrição do grupo.
    display_name- (Obrigatório) O nome de exibição do grupo.
    external_senders_allowed- (Opcional) Indica se pessoas externas à organização podem enviar mensagens ao grupo. Só pode ser definido para grupos Unificados.
    hide_from_address_lists- (Opcional) Indica se o grupo é exibido em certas partes da interface do usuário do Outlook: no Catálogo de Endereços, em listas de endereços para selecionar destinatários de mensagens e na caixa de diálogo Procurar Grupos para pesquisar grupos. Só pode ser definido para grupos Unificados.
    hide_from_outlook_clients- (Opcional) Indica se o grupo é exibido em clientes do Outlook, como Outlook para Windows e Outlook na Web. Só pode ser definido para grupos Unificados.
    mail_enabled- (Opcional) Se o grupo é um email habilitado, com uma caixa de correio de grupo compartilhada. Pelo menos um de mail_enabledou security_enableddeve ser especificado. Somente grupos do Microsoft 365 podem ser habilitados para email (veja a typespropriedade).
    mail_nickname- (Opcional) O alias de e-mail para o grupo, exclusivo na organização. Obrigatório para grupos habilitados para e-mail. Alterar isso força a criação de um novo recurso.
    members- (Opcional) Um conjunto de membros que devem estar presentes neste grupo. Os tipos de objetos suportados são Usuários, Grupos ou Principais de Serviço. Não pode ser usado com o dynamic_membershipbloco.
    onpremises_group_type- (Opcional) O tipo de grupo local em que o grupo AAD será gravado, quando o writeback estiver habilitado. Os valores possíveis são UniversalDistributionGroup, UniversalMailEnabledSecurityGroup, ou UniversalSecurityGroup.
    prevent_duplicate_names- (Opcional) Se true, retornará um erro se um grupo existente for encontrado com o mesmo nome. O padrão é false.
    provisioning_options- (Opcional) Um conjunto de opções de provisionamento para um grupo do Microsoft 365. O único valor suportado é Team. Veja a documentação oficial para detalhes. Alterar isso força a criação de um novo recurso.
    security_enabled- (Opcional) Se o grupo é um grupo de segurança para controlar o acesso a recursos no aplicativo. Pelo menos um de security_enabledou mail_enableddeve ser especificado. Um grupo do Microsoft 365 pode ter segurança habilitada e email habilitado (veja a typespropriedade).
    theme- (Opcional) O tema de cor para um grupo do Microsoft 365. Os valores possíveis são Blue, Green, Orange, Pink, Purple, Redou Teal. Por padrão, nenhum tema é definido.
    types- (Opcional) Um conjunto de tipos de grupo para configurar para o grupo. Os valores suportados são DynamicMembership, que denota um grupo com associação dinâmica, e Unified, que especifica um grupo do Microsoft 365. Obrigatório quando mail_enabledfor true. Alterar isso força a criação de um novo recurso.
    visibility- (Opcional) A política de ingresso no grupo e a visibilidade do conteúdo do grupo. Os valores possíveis são Private, Public, ou Hiddenmembership. Somente grupos do Microsoft 365 podem ter Hiddenmembershipvisibilidade e esse valor deve ser definido quando o grupo é criado. Por padrão, os grupos de segurança receberão Privatevisibilidade e os grupos do Microsoft 365 receberão Publicvisibilidade.
    writeback_enabled- (Opcional) Se o grupo será gravado de volta no Active Directory local configurado quando o Azure AD Connect for usado.
    owners- (Opcional) Um conjunto de IDs de objeto de principais que receberão a propriedade do grupo. Os tipos de objeto suportados são usuários ou principais de serviço. Por padrão, o principal que está sendo usado para executar o Terraform é atribuído como o único proprietário. Os grupos não podem ser criados sem proprietários ou ter todos os seus proprietários removidos.
    dynamic_membership- (Opcional) Um dynamic_membershipbloco conforme documentado abaixo. Obrigatório quando typescontém DynamicMembership. Não pode ser usado com a memberspropriedade.
      enabled- (Obrigatório) Se o processamento de regras está "Ativado" (verdadeiro) ou "Pausado" (falso).
      rule- (Obrigatório) A regra que determina a associação deste grupo. Para mais informações, veja a documentação oficial sobre a sintaxe das regras de associação .
  EOF
}

variable "dynamic_membership" {
  type = object({
    enabled = bool
    rule = string
  })
  default = null
  description = <<EOF
    dynamic_membership- (Opcional) Um dynamic_membershipbloco conforme documentado abaixo. Obrigatório quando typescontém DynamicMembership. Não pode ser usado com a memberspropriedade.
    enabled- (Obrigatório) Se o processamento de regras está "Ativado" (verdadeiro) ou "Pausado" (falso).
    rule- (Obrigatório) A regra que determina a associação deste grupo. Para mais informações, veja a documentação oficial sobre a sintaxe das regras de associação .
  EOF
}

variable "group_object_id" {
  description = "(Obrigatório) Apenas o ID do grupo que será usado para pertencer"
  type        = string
  default     = null
}

variable "user_object_id" {
  description = "(Obrigatório) Apenas string de ID do objeto do usuário"
  type        = string
  default     = null
}

variable "enable_attachments_groups" {
  description = "Gerencia o attachment do usuário a um grupo."
  type = bool
  default = false
}

variable "attachments" {
  description = "Objeto de attachments entre users para grupos"
  type = map(object({
    group_object_id = string
    member_object_id   = string
  }))
  default = null
}
