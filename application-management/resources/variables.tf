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

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = null
}

variable "create_resource_group" {
  description = "Gerencia a criação do RG"
  default     = false
}

variable "location" {
  description = "O local/região para manter todos os recursos da sua rede. Para obter a lista de todos os locais com formato de tabela do Azure CLI, execute 'az account list-locations -o table'"
  default     = ""
}

variable "virtual_network_name" {
  description = "O nome da rede virtual"
  default     = ""
}

variable "vnet_resource_group_name" {
  description = "O nome do grupo de recursos onde a rede virtual é criada"
  default     = null
}

variable "subnet_name" {
  description = "O nome da sub-rede a utilizar no conjunto de escala VM"
  default     = ""
}

variable "app_gateway_name" {
  description = "O nome do gateway de aplicativo"
  default     = ""
}

variable "log_analytics_workspace_name" {
  description = "O nome do espaço de trabalho do Log Analytics"
  default     = null
}

variable "storage_account_name" {
  description = "O nome da conta de armazenamento do hub para armazenar logs"
  default     = null
}

variable "domain_name_label" {
  description = "Rótulo para o nome de domínio. Será usado para compor o FQDN."
  default     = null
}

variable "enable_http2" {
  description = "O HTTP2 está habilitado no recurso de gateway de aplicativo?"
  default     = false
}

variable "zones" {
  description = "Uma coleção de zonas de disponibilidade para espalhar o Gateway de Aplicativo."
  type        = list(string)
  default     = [] #["1", "2", "3"]
}

variable "firewall_policy_id" {
  description = "O ID da política de firewall de aplicativo Web que pode ser associada ao gateway de aplicativo"
  default     = null
}

variable "sku" {
  description = "O modelo de precificação de SKU de v1 e v2"
  type = object({
    name     = string
    tier     = string
    capacity = optional(number)
  })
  default = {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }
}

variable "autoscale_configuration" {
  description = "Capacidade mínima ou máxima para escalonamento automático. Os valores aceitos são para Mínimo no intervalo de 0 a 100 e para Máximo no intervalo de 2 a 125"
  type = object({
    min_capacity = number
    max_capacity = optional(number)
  })
  default = null
}

variable "private_ip_address" {
  description = "Endereço IP privado a ser atribuído ao Load Balancer."
  default     = null
}

variable "backend_address_pools" {
  description = "Lista de pools de endereços de back-end"
  type = list(object({
    name         = string
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  }))
  default = []
}

variable "backend_http_settings" {
  description = "Lista de configurações HTTP de back-end."
  type = list(object({
    name                                = string
    cookie_based_affinity               = string
    affinity_cookie_name                = optional(string)
    path                                = optional(string)
    enable_https                        = bool
    probe_name                          = optional(string)
    request_timeout                     = number
    host_name                           = optional(string)
    pick_host_name_from_backend_address = optional(bool)
    authentication_certificate = optional(object({
      name = string
    }))
    trusted_root_certificate_names = optional(list(string))
    connection_draining = optional(object({
      enable_connection_draining = bool
      drain_timeout_sec          = number
    }))
  }))
  default = []
}

variable "http_listeners" {
  description = "Lista de ouvintes HTTP/HTTPS. O nome do certificado SSL é obrigatório"
  type = list(object({
    name                 = string
    host_name            = optional(string)
    host_names           = optional(list(string))
    require_sni          = optional(bool)
    ssl_certificate_name = optional(string)
    firewall_policy_id   = optional(string)
    ssl_profile_name     = optional(string)
    custom_error_configuration = optional(list(object({
      status_code           = string
      custom_error_page_url = string
    })))
  }))
  default = []
}

variable "request_routing_rules" {
  description = "Lista de regras de roteamento de solicitações a serem usadas para ouvintes."
  type = list(object({
    name                        = string
    rule_type                   = string
    http_listener_name          = string
    backend_address_pool_name   = optional(string)
    backend_http_settings_name  = optional(string)
    redirect_configuration_name = optional(string)
    rewrite_rule_set_name       = optional(string)
    url_path_map_name           = optional(string)
    priority                    = number
  }))
  default = []
}

variable "identity_ids" {
  description = "Especifica uma lista com um único ID de identidade gerido pelo utilizador a ser atribuído ao Gateway de Aplicação"
  default     = null
}

variable "authentication_certificates" {
  description = "Certificados de autenticação para permitir o back-end com o Azure Application Gateway"
  type = list(object({
    name = string
    data = string
  }))
  default = []
}

variable "trusted_root_certificates" {
  description = "Certificados raiz confiáveis ​​para permitir o back-end com o Azure Application Gateway"
  type = list(object({
    name = string
    data = string
  }))
  default = []
}

variable "ssl_policy" {
  description = "Configuração SSL do Gateway de Aplicativo"
  type = object({
    disabled_protocols   = optional(list(string))
    policy_type          = optional(string)
    policy_name          = optional(string)
    cipher_suites        = optional(list(string))
    min_protocol_version = optional(string)
  })
  default = null
}

variable "ssl_certificates" {
  description = "Lista de dados de certificados SSL para gateway de aplicativo"
  type = list(object({
    name                = string
    data                = optional(string)
    password            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default = []
}

variable "health_probes" {
  description = "Lista de sondagens de integridade usadas para testar a integridade dos pools de back-end."
  type = list(object({
    name                                      = string
    host                                      = string
    interval                                  = number
    path                                      = string
    timeout                                   = number
    unhealthy_threshold                       = number
    port                                      = optional(number)
    pick_host_name_from_backend_http_settings = optional(bool)
    minimum_servers                           = optional(number)
    match = optional(object({
      body        = optional(string)
      status_code = optional(list(string))
    }))
  }))
  default = []
}

variable "url_path_maps" {
  description = "Lista de mapas de caminhos de URL associados a regras baseadas em caminhos."
  type = list(object({
    name                                = string
    default_backend_http_settings_name  = optional(string)
    default_backend_address_pool_name   = optional(string)
    default_redirect_configuration_name = optional(string)
    default_rewrite_rule_set_name       = optional(string)
    path_rules = list(object({
      name                        = string
      backend_address_pool_name   = optional(string)
      backend_http_settings_name  = optional(string)
      paths                       = list(string)
      redirect_configuration_name = optional(string)
      rewrite_rule_set_name       = optional(string)
      firewall_policy_id          = optional(string)
    }))
  }))
  default = []
}

variable "redirect_configuration" {
  description = "lista de mapas para configurações de redirecionamento"
  type        = list(map(string))
  default     = []
}

variable "custom_error_configuration" {
  description = "Configuração de erro personalizada de nível global para gateway de aplicativo"
  type        = list(map(string))
  default     = []
}

variable "rewrite_rule_set" {
  description = "Lista do conjunto de regras de reescrita, incluindo regras de reescrita"
  type        = any
  default     = []
}

variable "waf_configuration" {
  description = "Suporte ao Firewall de Aplicativo Web para seu Gateway de Aplicativo do Azure"
  type = object({
    firewall_mode            = string
    rule_set_version         = string
    file_upload_limit_mb     = optional(number)
    request_body_check       = optional(bool)
    max_request_body_size_kb = optional(number)
    disabled_rule_group = optional(list(object({
      rule_group_name = string
      rules           = optional(list(string))
    })))
    exclusion = optional(list(object({
      match_variable          = string
      selector_match_operator = optional(string)
      selector                = optional(string)
    })))
  })
  default = null
}

variable "agw_diag_logs" {
  description = "Detalhes da categoria de monitoramento do gateway de aplicativo para configuração de diagnóstico do Azure"
  default     = ["ApplicationGatewayAccessLog", "ApplicationGatewayPerformanceLog", "ApplicationGatewayFirewallLog"]
}

variable "pip_diag_logs" {
  description = "Detalhes da categoria de monitoramento de IP público do balanceador de carga para configuração de diagnóstico do Azure"
  default     = ["DDoSProtectionNotifications", "DDoSMitigationFlowLogs", "DDoSMitigationReports"]
}

variable "tags" {
  description = "Um map de tags para adicionar a todos os recursos"
  type        = map(string)
  default     = {}
}