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

variable "create_resource_group" {
  description = "Se deve criar um grupo de recursos e usá-lo para todos os recursos de rede"
  default     = false
}

variable "create_dns_zone" {
  description = "Se deve criar uma DNS Zone para utilizá-la nos recursos."
  default     = false
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
  default     = null
}

variable "dns_zone_name" {
  description = "Nome do Dns Zone"
  type        = string
  default     = null
}

variable "records_inserts" {
  type = list(object({
    name    = string
    type    = string
    ttl     = number
    records = list(string)
    flags   = optional(number)
    tag     = optional(string)
    value   = optional(string)
  }))
  description = "Lista de objetos de registro DNS a serem gerenciados, na estrutura padrão do terraform dns."
}

variable "dns_zone_settings" {
  type = object({
    tags = optional(map(string))
    soa_record = optional(object({
      email = string
      host_name = optional(string)
      expire_time = optional(string)
      minimum_ttl = optional(number)
      retry_time = optional(number)
      serial_number = optional(number)
      ttl = optional(number)
      tags = optional(map(string))
    }))
  })
}

variable "tags" {
  description = "Um mapa de tags para adicionar a todos os recursos"
  type        = map(string)
  default     = {}
}