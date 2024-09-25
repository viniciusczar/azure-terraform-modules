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

variable "path_export_credentials" {
  description = "Local path to save the credential created"
  type        = string
  default     = "/home/viniciusczar/Downloads/azure+oci/azure/credenciais" #  DevOps # 
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
  default     = null
}

variable "create_ad_group" {
  description = "Gerenciar criação de grupo ad. O padrão é false"
  type = bool
  default = false
}

variable "user_configs" {
  type = object({
    display_name               = optional(string)
    given_name                 = optional(string)
    job_title                  = optional(string)
    force_password_change      = optional(bool, false)
    disable_password_expiration= optional(bool, false)
    disable_strong_password    = optional(bool, false)
    account_enabled            = optional(bool, true)
    age_group                  = optional(string)
    business_phones            = optional(list(string))
    city                       = optional(string)
    company_name               = optional(string)
    consent_provided_for_minor = optional(string)
    cost_center                = optional(string)
    country                    = optional(string)
    department                 = optional(string)
    division                   = optional(string)
    employee_id                = optional(string)
    employee_type              = optional(string)
    fax_number                 = optional(number)
    mail                       = optional(string)
    manager_id                 = optional(string)
    mobile_phone               = optional(string)
    office_location            = optional(string)
    onpremises_immutable_id    = optional(string)
    other_mails                = optional(list(string))
    postal_code                = optional(string)
    preferred_language         = optional(string)
    show_in_address_list       = optional(string)
    state                      = optional(string)
    street_address             = optional(string)
    surname                    = optional(string)
    usage_location             = optional(string)
  })
  default = null
  description = <<EOF
    account_enabled- (Opcional) Se a conta deve ou não ser habilitada.
    age_group- (Opcional) A faixa etária do usuário. Os valores suportados são Adult, NotAdulte Minor. Omita esta propriedade ou especifique uma string em branco para desconfigurar.
    business_phones- (Opcional) Uma lista de números de telefone para o usuário. Apenas um número pode ser definido para esta propriedade. Somente leitura para usuários sincronizados com o Azure AD Connect.
    city- (Opcional) A cidade em que o usuário está localizado.
    company_name- (Opcional) O nome da empresa à qual o usuário está associado. Esta propriedade pode ser útil para descrever a empresa da qual um usuário externo vem.
    consent_provided_for_minor- (Opcional) Se o consentimento foi obtido para menores. Os valores suportados são Granted, Deniede NotRequired. Omita esta propriedade ou especifique uma string em branco para desconfigurar.
    cost_center- (Opcional) O centro de custo associado ao usuário.
    country- (Opcional) O país/região em que o usuário está localizado. Exemplos incluem: NO, JP, e GB.
    department- (Opcional) O nome do departamento no qual o usuário trabalha.
    disable_password_expiration- (Opcional) Se a senha do usuário está isenta de expiração. O padrão é false.
    disable_strong_password- (Opcional) Se o usuário tem permissão para senhas mais fracas do que a política padrão a ser especificada. O padrão é false.
    display_name- (Obrigatório) O nome a ser exibido no catálogo de endereços do usuário.
    division- (Opcional) O nome da divisão na qual o usuário trabalha.
    employee_id- (Opcional) O identificador de funcionário atribuído ao usuário pela organização.
    employee_type- (Opcional) Captura o tipo de trabalhador da empresa. Por exemplo, Employee, Contractor, Consultant ou Vendor.
    fax_number- (Opcional) O número de fax do usuário.
    force_password_change- (Opcional) Se o usuário é forçado a alterar a senha durante o próximo login. Só entra em vigor ao alterar também a senha. O padrão é false.
    given_name- (Opcional) O nome próprio (primeiro nome) do usuário.
    job_title- (Opcional) Cargo do usuário.
    mail- (Opcional) O endereço SMTP para o usuário. Esta propriedade não pode ser desdefinida uma vez especificada.
    manager_id- (Opcional) O ID do objeto do gerente do usuário.
    mobile_phone- (Opcional) O número de telefone celular principal do usuário.
    office_location- (Opcional) O local do escritório no local de trabalho do usuário.
    onpremises_immutable_id- (Opcional) O valor usado para associar uma conta de usuário do Active Directory local ao seu objeto de usuário do Azure AD. Isso deve ser especificado se você estiver usando um domínio federado para a user_principal_namepropriedade do usuário ao criar uma nova conta de usuário.
    other_mails- (Opcional) Uma lista de endereços de e-mail adicionais para o usuário.
    postal_code- (Opcional) O código postal para o endereço postal do usuário. O código postal é específico para o país/região do usuário. Nos Estados Unidos da América, este atributo contém o código postal.
    preferred_language- (Opcional) O idioma preferido do usuário, na notação ISO 639-1.
    show_in_address_list- (Opcional) Se a lista de endereços global do Outlook deve ou não incluir este usuário. O padrão é true.
    state- (Opcional) O estado ou província no endereço do usuário.
    street_address- (Opcional) O endereço da rua do local comercial do usuário.
    surname- (Opcional) O sobrenome do usuário (nome de família ou sobrenome).
    usage_location- (Opcional) O local de uso do usuário. Obrigatório para usuários que receberão licenças devido a requisitos legais para verificar a disponibilidade de serviços em países. O local de uso é um código de país de duas letras (padrão ISO 3166). Exemplos incluem: NO, JP, e GB. Não pode ser redefinido para nulo depois de definido.
    user_principal_name- (Obrigatório) O nome principal do usuário (UPN) do usuário.
  EOF
}