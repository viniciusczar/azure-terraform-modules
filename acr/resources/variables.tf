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

variable "location" {
  description = "O local/região para manter todos os recursos da sua rede. Para obter a lista de todos os locais com formato de tabela do Azure CLI, execute 'az account list-locations -o table'"
  default     = ""
}

variable "azurerm_container_registry_name" {
  description = "(Obrigatório) Especifica o nome do Container Registry. Somente caracteres alfanuméricos são permitidos. Alterar isso força a criação de um novo recurso."
  type        = string
  default     = null
}

variable "create_resource_group" {
  description = "Se deve criar um grupo de recursos e usá-lo para todos os recursos de rede"
  default     = false
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
  default     = null
}
variable "container_registry_config" {
  description = "Gerencia um Registro de Contêiner do Azure"
  type = object({
    name                          = string
    admin_enabled                 = optional(bool)
    sku                           = optional(string)
    public_network_access_enabled = optional(bool)
    quarantine_policy_enabled     = optional(bool)
    zone_redundancy_enabled       = optional(bool)
  })
  default = null
}

variable "georeplications" {
  description = "Uma lista de locais do Azure onde o registo de Container deve ser replicado geograficamente"
  type = list(object({
    location                = string
    zone_redundancy_enabled = optional(bool)
  }))
  default = []
}

variable "network_rule_set" {
  description = "Gerir regras de rede para registos de Container Azure"
  type = object({
    default_action = optional(string)
    ip_rule = optional(list(object({
      ip_range = string
    })))
    virtual_network = optional(list(object({
      subnet_id = string
    })))
  })
  default = null
}

variable "retention_policy" {
  description = "Defina uma política de retenção para manifestos não marcados"
  type = object({
    days    = optional(number)
    enabled = optional(bool)
  })
  default = null
}

variable "enable_content_trust" {
  description = "Valor booliano para habilitar ou desabilitar a confiança de conteúdo no Registro de Contêiner do Azure"
  default     = false
}

variable "identity_ids" {
  description = "Especifica uma lista de IDs de identidade gerenciados pelo usuário a serem atribuídos. Isso é necessário quando `type` é definido como `UserAssigned` ou `SystemAssigned, UserAssigned`"
  default     = null
}

variable "encryption" {
  description = "Criptografar o registro usando uma chave gerenciada pelo cliente"
  type = object({
    key_vault_key_id   = string
    identity_client_id = string
  })
  default = null
}

variable "scope_map" {
  description = "Manages an Azure Container Registry scope map. Scope Maps are a preview feature only available in Premium SKU Container registries."
  type = map(object({
    actions = list(string)
  }))
  default = null
}

variable "container_registry_webhooks" {
  description = "Gerencia um Webhook do Registro de Contêiner do Azure"
  type = map(object({
    service_uri    = string
    actions        = list(string)
    status         = optional(string)
    scope          = string
    custom_headers = map(string)
  }))
  default = null
}

variable "enable_private_endpoint" {
  description = "Gerencia um ponto final privado para o Registro de Contêiner do Azure"
  default     = false
}

variable "existing_subnet_id" {
  description = "O ID do recurso da sub-rede existente"
  default     = null
}

variable "virtual_network_name" {
  description = "O nome da rede virtual"
  default     = ""
}

variable "existing_private_dns_zone" {
  description = "Nome da zona DNS privada existente"
  default     = null
}

variable "azurerm_private_dns_zone_name" {
  description = "O DNS privado que será utilizado no link privado"
  default     = null
}

variable "private_subnet_address_prefix" {
  description = "O nome da sub-rede para private endpoints"
  default     = null
}

variable "log_analytics_workspace_name" {
  description = "O nome do espaço de worskpace do Log Analytics"
  default     = null
}

variable "storage_account_name" {
  description = "O nome da conta de armazenamento do hub para armazenar logs"
  default     = null
}

variable "acr_diag_logs" {
  description = "Detalhes da categoria de monitoramento do gateway de aplicativo para configuração de diagnóstico do Azure"
  default     = ["ContainerRegistryRepositoryEvents", "ContainerRegistryLoginEvents"]
}

variable "user_assigned_identity_client_id" {
  description = "Client Id do Azure AD para admin do ACR"
  default     = null
}

variable "tags" {
  description = "Um mapa de tags para adicionar a todos os recursos"
  type        = map(string)
  default     = {}
}