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

variable "mysqlserver_name" {
  description = "(Obrigatório) Especifica o nome do MariaDB Server. Alterar isso força a criação de um novo recurso."
  type        = string
  default     = null
}

variable "admin_username" {
  description = "(Opcional) O login do Administrator para o MariaDB Server. Alterar isso força a criação de um novo recurso."
  type        = string
  default     = null
}

variable "admin_password" {
  description = "(Opcional) A senha associada ao administrator_loginservidor MariaDB."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
  default     = null
}

variable "create_resource_group" {
  description = "Se deve criar um grupo de recursos e usá-lo para todos os recursos de rede"
  default     = true
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

variable "mysqlserver_settings" {
  type = object({
    sku_name                          = string
    version                           = string
    source_server_id                  = optional(string)
    replication_role                  = optional(string)
    backup_retention_days             = optional(number)
    geo_redundant_backup_enabled      = optional(bool)
    point_in_time_restore_time_in_utc = optional(string)
    create_mode                       = optional(string)
    database_name                     = string
    charset                           = string
    collation                         = string
    zone                              = optional(number)
  })
  description = <<EOF
    MySQL server settings
    (Obrigatório) - sku_name - Especifica o nome do SKU para este servidor MySQL. O nome do SKU segue o padrão camada + família + núcleos (por exemplo, B_Gen4_1, GP_Gen5_8). Para obter mais informações, consulte a documentação do produto. Os valores possíveis são B_Gen5_1, B_Gen5_2, GP_Gen5_2, GP_Gen5_4, GP_Gen5_8, GP_Gen5_16, GP_Gen5_32, MO_Gen5_2, MO_Gen5_4, MO_Gen5_8 e MO_Gen5_16.
    (Opcional) - backup_retention_days - Dias de retenção de backup para o servidor, os valores suportados estão entre 7 e 35 dias.
    (Opcional) - source_server_id - O ID do recurso do MySQL Flexible Server de origem a ser restaurado. Obrigatório quando create_mode é PointInTimeRestore, GeoRestore e Replica. Alterar isso força a criação de um novo Servidor Flexível MySQL.
    (Opcional) - replication_role - A função de replicação. O valor possível é None.
    (Opcional) - point_in_time_restore_time_in_utc - O momento para restaurar de Creation_source_server_id quando create_mode é PointInTimeRestore. Alterar isso força a criação de um novo Servidor Flexível MySQL.
    (Opcional) - create_mode - (Opcional) O modo de criação. Pode ser usado para restaurar ou replicar servidores existentes. Os valores possíveis são Default, Replica, GeoRestore, e PointInTimeRestore. O padrão é Default.
    (Opcional) - geo_redundant_backup_enabled - Ative/desative os backups de servidor geo-redundantes. Isso permite que você escolha entre armazenamento de backup localmente redundante ou geo-redundante nas camadas General Purpose e Memory Optimized. Quando os backups são armazenados em armazenamento de backup geo-redundante, eles não são apenas armazenados na região em que seu servidor está hospedado, mas também são replicados para um data center pareado. Isso fornece melhor proteção e capacidade de restaurar seu servidor em uma região diferente no caso de um desastre. Isso não é suportado para a camada Basic.
    (Obrigatório) - database_name - (Obrigatório) Especifica o nome do banco de dados MySQL, que precisa ser um identificador MySQL válido. Alterar isso força a criação de um novo recurso.
    (Obrigatório) - charset - Especifica o Charset para o banco de dados MySQL, que precisa ser um Charset MySQL válido. Alterar isso força a criação de um novo recurso.
    (Obrigatório) - collation - Especifica o agrupamento para o banco de dados MySQL, que precisa ser um agrupamento MySQL válido. Alterar isso força a criação de um novo recurso.
    (Obrigatório) - version - Especifica a versão do MySQL a ser usada. Os valores possíveis são 10.2 e 10.3. Alterar isso força a criação de um novo recurso.
    (Opcional) - zone - Especifica a zona de disponibilidade na qual este servidor flexível MySQL deve estar localizado. Os valores possíveis são 1, 2 e 3.
  EOF
  default     = null
}

variable "storage" {
  type = object({
    auto_grow_enabled  = optional(bool, true)
    io_scaling_enabled = optional(bool, false)
    iops               = optional(number)
    size_gb            = optional(number)
  })
  default     = null
  description = <<EOF
    Um bloco de armazenamento conforme definido abaixo.
      (Opcional) - auto_grow_enabled - O crescimento automático do armazenamento deve estar ativado? O padrão é true.
      (Opcional) - io_scaling_enabled - O IOPS deve ser dimensionado automaticamente? Se for verdade, os iops não podem ser definidos. O padrão é falso.
      (Opcional) - iops - O IOPS de armazenamento para o servidor flexível MySQL. Os valores possíveis estão entre 360 ​​e 20.000.
      (Opcional) - size_gb - O armazenamento máximo permitido para o servidor flexível MySQL. Os valores possíveis estão entre 20 e 16384.
  EOF
}

variable "high_availability" {
  type = object({
    mode                      = string
    standby_availability_zone = optional(number)
  })
  default     = null
  description = <<EOF
    Um bloco high_availability conforme definido abaixo.
      (Obrigatório) - mode - O modo de alta disponibilidade para o Servidor Flexível MySQL. Os valores possíveis são SameZone e ZoneRedundant.
      (Opcional) - standby_availability_zone - Especifica a zona de disponibilidade na qual o servidor flexível em espera deve estar localizado. Os valores possíveis são 1, 2 e 3.
  EOF
}

variable "maintenance_window" {
  type = object({
    day_of_week  = optional(number)
    start_hour   = optional(number)
    start_minute = optional(number)
  })
  default     = null
  description = <<EOF
    (Opcional) - day_of_week - O dia da semana para a janela de manutenção. O padrão é 0.
    (Opcional) - start_hour - A hora de início da janela de manutenção. O padrão é 0.
    (Opcional) - start_minuto - O minuto de início da janela de manutenção. O padrão é 0.
  EOF
}

variable "tags" {
  description = "(Opcional) Um mapeamento de tags para atribuir ao recurso."
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_already_exists" {
  description = "Verifica se já existe log analytics workspace"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_name" {
  description = "O nome do espaço de trabalho do Log Analytics"
  default     = null
}

variable "enable_logs_to_storage_account" {
  description = "Crie uma conta de armazenamento para onde os logs devem ser enviados"
  default     = false
}

variable "storage_account_name" {
  description = "O nome do nome da conta de armazenamento"
  default     = null
}

variable "create_user_assigned_identity" {
  description = "Crie uma identity user assinado para vincular ao ad"
  default     = false
}

variable "delegated_subnet_name" {
  description = "O Nome da subnet a ser vinculado o postgresql Server"
  default     = null
}

variable "random_password_length" {
  description = "O comprimento desejado da senha aleatória criada por este módulo"
  default     = 24
}

variable "log_retention_days" {
  description = "Especifica o número de dias a serem mantidos nos registros de auditoria do Threat Detection"
  default     = "30"
}

variable "mysql_configuration" {
  description = "Define um valor de configuração MySQL em um MySQL Server"
  type        = map(string)
  default     = {}
}

variable "firewall_rules" {
  description = "Faixa de endereços IP para permitir conexões de firewall."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = null
}

variable "ad_admin_login_name" {
  description = "O nome de login do principal a ser definido como administrador do servidor"
  default     = null
}

variable "user_assigned_identity_name" {
  description = "O nome de login do principal a ser criado como administrador do servidor"
  default     = null
}

variable "customer_managed_key" {
  type = object({
    key_vault_key_id                     = optional(string)
    primary_user_assigned_identity_id    = optional(string)
    geo_backup_key_vault_key_id          = optional(string)
    geo_backup_user_assigned_identity_id = optional(string)
  })
  default     = null
  description = <<EOF
    Um bloco customer_owned_key conforme definido abaixo.
      (Opcional) - key_vault_key_id – O ID da chave do Key Vault.
      (Opcional) - primary_user_assigned_identity_id – Especifica o ID de identidade gerenciado pelo usuário principal para uma chave gerenciada pelo cliente. Deve ser adicionado com Identity_ids.
      (Opcional) - geo_backup_key_vault_key_id – O ID da chave do Key Vault de backup geográfico. Ele não pode cruzar a região e precisa da chave gerenciada pelo cliente na mesma região do backup geográfico.
      (Opcional) geo_backup_user_assigned_identity_id – O ID de identidade gerenciada pelo usuário de backup geográfico para uma chave gerenciada pelo cliente. Deve ser adicionado com Identity_ids. Ele não pode cruzar a região e precisa de identidade na mesma região do backup geográfico.
  EOF
}

variable "subnet_id" {
  description = "O ID do recurso da sub-rede"
  default     = null
}

variable "enable_private_dns_zone_endpoint" {
  description = "Gerencia um ponto final privado para banco de dados do Azure para MySQL"
  default     = false
}

variable "create_private_dns_zone_name" {
  description = "Gerencia a criação de um dns de zona privada"
  default     = false
}

variable "virtual_network_name" {
  description = "O nome da rede virtual"
  default     = ""
}

variable "subnet_address_prefix" {
  description = "Intervalo CIDR para subnet"
  default     = null
}

variable "azurerm_private_dns_zone_name" {
  description = "O DNS privado que será utilizado no link privado"
  default     = null
}

variable "extaudit_diag_logs" {
  description = "Detalhes da categoria de monitoramento de banco de dados para configuração de diagnóstico do Azure"
  default     = ["MySQLSlowLogs", "MySQLAuditLogs"]
}
