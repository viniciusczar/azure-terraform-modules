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
  description = "Região do Azure"
  type        = string
  default     = null
}

variable "create_resource_group" {
  description = "Se deve criar um grupo de recursos e usá-lo para todos os recursos de rede"
  default     = true
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
  default     = null
}

variable "storage_account_name" {
  description = "O nome do nome da conta de armazenamento"
  default     = null
}
variable "random_password_length" {
  description = "O comprimento desejado da senha aleatória criada por este módulo"
  default     = 32
}

variable "enable_sql_server_extended_auditing_policy" {
  description = "Gerencia a política de auditoria estendida para SQL Server"
  default     = true
}

variable "enable_database_extended_auditing_policy" {
  description = "Gerencia a política de Auditoria Estendida para banco de dados SQL"
  default     = false
}

variable "enable_threat_detection_policy" {
  description = ""
  default     = false
}

variable "sqlserver_name" {
  description = "SQL server Name"
  default     = ""
}

variable "mssql_version" {
  description = "The version for the new server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). Changing this forces a new resource to be created."
  type = string
  default     = "12.0"
}

variable "admin_username" {
  description = "O nome de login do administrador para o novo SQL Server"
  default     = null
}

variable "admin_password" {
  description = "A senha associada ao usuário admin_username"
  default     = null
}

variable "database_name" {
  description = "O nome do banco de dados"
  default     = ""
}

variable "sql_database_edition" {
  description = "A edição do banco de dados a ser criado"
  default     = "Standard"
}

variable "sqldb_service_objective_name" {
  description = "O nome do objetivo de serviço do banco de dados"
  default     = "S1"
}

variable "log_retention_days" {
  description = "Especifica o número de dias a serem mantidos nos registros de auditoria do Threat Detection"
  default     = "30"
}

variable "threat_detection_audit_logs_retention_days" {
  description = "Especifica o número de dias a serem mantidos nos registros de auditoria do Threat Detection."
  default     = 0
}

variable "enable_vulnerability_assessment" {
  description = "Gerencia a avaliação de vulnerabilidade para um MS SQL Server"
  default     = false
}

variable "email_addresses_for_alerts" {
  description = "Uma lista de endereços de e-mail para os quais os alertas devem ser enviados."
  type        = list(any)
  default     = []
}

variable "disabled_alerts" {
  description = "Especifica uma série de alertas desabilitados. Os valores permitidos são: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action."
  type        = list(any)
  default     = []
}

variable "ad_admin_login_name" {
  description = "O nome de login do principal a ser definido como administrador do servidor"
  default     = null
}

variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default     = null
  description = <<EOF
    Um bloco de identidade oferece suporte ao seguinte:
    (Obrigatório) - type - Especifica o tipo de Identidade de Serviço Gerenciado que deve ser configurada neste Servidor Flexível MySQL. O único valor possível é UserAssigned.
    (Obrigatório) - identity_ids - Uma lista de IDs de identidade gerenciada atribuídas pelo usuário a serem atribuídas a este servidor flexível MySQL.
  EOF
}

variable "enable_firewall_rules" {
  description = "Gerenciar uma regra de firewall SQL do Azure"
  default     = false
}

variable "enable_failover_group" {
  description = "Criar um grupo de failover de bancos de dados em uma coleção de servidores SQL do Azure"
  default     = false
}

variable "secondary_sql_server_location" {
  description = "Especifica o local do Azure com suporte para criar recursos secundários do SQL Server"
  default     = "northeurope"
}

variable "enable_private_endpoint" {
  description = "Gerencia um ponto final privado para banco de dados SQL"
  default     = false
}

variable "azurerm_private_dns_zone_name" {
  description = "O DNS privado que será utilizado no link privado"
  default     = null
}

variable "virtual_network_name" {
  description = "O nome da rede virtual"
  default     = ""
}

variable "private_subnet_address_prefix" {
  description = "O nome da sub-rede para private endpoints"
  default     = null
}

variable "existing_vnet_id" {
  description = "O ID do recurso da rede virtual existente"
  default     = null
}

variable "existing_subnet_id" {
  description = "O ID do recurso da sub-rede existente"
  default     = null
}

variable "existing_private_dns_zone" {
  description = "Nome da private DNS zone existente"
  default     = null
}

variable "firewall_rules" {
  description = "Faixa de endereços IP para permitir conexões de firewall."
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = []
}

variable "enable_log_monitoring" {
  description = "Habilitar eventos de auditoria para o Azure Monitor?"
  default     = false
}

variable "initialize_sql_script_execution" {
  description = "Permitir/negar criar e inicializar um banco de dados Microsoft SQL Server"
  default     = false
}

variable "sqldb_init_script_file" {
  description = "Nome do arquivo SQL Script para criar e inicializar o banco de dados"
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "Especifica a ID de um espaço de trabalho do Log Analytics para onde os dados de diagnóstico serão enviados"
  default     = null
}

variable "storage_account_id" {
  description = "O nome da conta de armazenamento para armazenar todos os registos de monitorização"
  default     = null
}

variable "extaudit_diag_logs" {
  description = "Detalhes da categoria de monitoramento de banco de dados para configuração de diagnóstico do Azure"
  default     = ["SQLSecurityAuditEvents", "SQLInsights", "AutomaticTuning", "QueryStoreRuntimeStatistics", "QueryStoreWaitStatistics", "Errors", "DatabaseWaitStatistics", "Timeouts", "Blocks", "Deadlocks"]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}