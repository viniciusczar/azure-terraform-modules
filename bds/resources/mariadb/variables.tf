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

variable "mariadb_server_name" {
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

variable "mariadb_settings" {
  type = object({
    sku_name                      = string
    version                       = string
    storage_mb                    = optional(number)
    auto_grow_enabled             = optional(bool)
    backup_retention_days         = optional(number)
    geo_redundant_backup_enabled  = optional(bool)
    public_network_access_enabled = optional(bool)
    ssl_enforcement_enabled       = bool
    create_mode                   = optional(string)
    creation_source_server_id     = optional(any)
    restore_point_in_time         = optional(any)
    database_name                 = string
    charset                       = string
    collation                     = string
    ssl_minimal_tls_version_enforced = optional(string, "TLS1_2")
  })
  description = <<EOF
    MariaDB server settings
    (Obrigatório) - sku_name - Especifica o nome do SKU para este servidor MariaDB. O nome do SKU segue o padrão camada + família + núcleos (por exemplo, B_Gen4_1, GP_Gen5_8). Para obter mais informações, consulte a documentação do produto. Os valores possíveis são B_Gen5_1, B_Gen5_2, GP_Gen5_2, GP_Gen5_4, GP_Gen5_8, GP_Gen5_16, GP_Gen5_32, MO_Gen5_2, MO_Gen5_4, MO_Gen5_8 e MO_Gen5_16.
    (Opcional) - auto_grow_enabled - Habilitar/Desabilitar o crescimento automático do armazenamento. O crescimento automático do armazenamento impede que seu servidor fique sem armazenamento e se torne somente leitura. Se o crescimento automático do armazenamento estiver habilitado, o armazenamento cresce automaticamente sem impactar a carga de trabalho. O valor padrão, se não for especificado explicitamente, é true. O padrão é true.
    (Opcional) - backup_retention_days - Dias de retenção de backup para o servidor, os valores suportados estão entre 7 e 35 dias.
    (Opcional) - create_mode - (Opcional) O modo de criação. Pode ser usado para restaurar ou replicar servidores existentes. Os valores possíveis são Default, Replica, GeoRestore, e PointInTimeRestore. O padrão é Default.
    (Opcional) - creation_source_server_id - Para modos de criação diferentes de Default, o ID do servidor de origem a ser usado.
    (Obrigatório) - ssl_enforcement_enabled - Especifica se o SSL deve ser imposto em conexões. Os valores possíveis são truee false.
    (Opcional) - geo_redundant_backup_enabled - Ative/desative os backups de servidor geo-redundantes. Isso permite que você escolha entre armazenamento de backup localmente redundante ou geo-redundante nas camadas General Purpose e Memory Optimized. Quando os backups são armazenados em armazenamento de backup geo-redundante, eles não são apenas armazenados na região em que seu servidor está hospedado, mas também são replicados para um data center pareado. Isso fornece melhor proteção e capacidade de restaurar seu servidor em uma região diferente no caso de um desastre. Isso não é suportado para a camada Basic.
    (Opcional) - public_network_access_enabled - Se o acesso à rede pública é permitido ou não para este servidor. O padrão é true.
    (Opcional) - restore_point_in_time - Quando create_modeé PointInTimeRestore, especifica o ponto no tempo para restaurar de creation_source_server_id. Deve ser fornecido no formato RFC33392013-11-08T22:00:40Z , por exemplo .
    (Obrigatório) - database_name - (Obrigatório) Especifica o nome do banco de dados MariaDB, que precisa ser um identificador MariaDB válido. Alterar isso força a criação de um novo recurso.
    (Obrigatório) - charset - Especifica o Charset para o banco de dados MariaDB, que precisa ser um Charset MariaDB válido. Alterar isso força a criação de um novo recurso.
    (Obrigatório) - collation - Especifica o agrupamento para o banco de dados MariaDB, que precisa ser um agrupamento MariaDB válido. Alterar isso força a criação de um novo recurso.
    (Opcional) - storage_mb - Armazenamento máximo permitido para um servidor. Os valores possíveis estão entre 5.120 MB (5 GB) e 1.024.000 MB (1 TB) para o SKU Básico e entre 5.120 MB (5 GB) e 4.096.000 MB (4 TB) para SKUs de uso geral/memória otimizada. Para obter mais informações, consulte a documentação do produto.
    (Obrigatório) - version_mariadb - Especifica a versão do MariaDB a ser usada. Os valores possíveis são 10.2 e 10.3. Alterar isso força a criação de um novo recurso.
    (Opcional) - ssl_minimal_tls_version_enforced - (Opcional) A versão mínima do TLS para suportar no servidor. Os valores possíveis são TLSEnforcementDisabled, TLS1_0, TLS1_1, e TLS1_2. O padrão é TLS1_2.
  EOF
    default = null
}

variable "tags" {
  description = "(Opcional) Um mapeamento de tags para atribuir ao recurso."
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_already_exists" {
  description = "Verifica se já existe log analytics workspace"
  type = bool
  default = true
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

variable "random_password_length" {
  description = "O comprimento desejado da senha aleatória criada por este módulo"
  default     = 24
}

variable "mariadb_configuration" {
  description = "Define um valor de configuração MariaDB em um servidor MariaDB"
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

variable "subnet_id" {
  description = "O ID do recurso da sub-rede"
  default     = null
}

variable "enable_private_endpoint" {
  description = "Gerencia um ponto final privado para banco de dados do Azure para MariaDB"
  default     = false
}

variable "virtual_network_name" {
  description = "O nome da rede virtual"
  default     = ""
}

variable "private_subnet_address_prefix" {
  description = "Intervalo CIDR para subnet privada"
  default     = null
}

variable "private_subnet_id" {
  description = "Subnet privada onde estará o link privado para o MariaDb Server"
  type        = string
  default     = null
}

variable "azurerm_private_dns_zone_name" {
  description = "O DNS privado que será utilizado no link privado"
  default     = null
}

variable "existing_private_dns_zone" {
  description = "Nome da zona DNS privada existente"
  default     = null
}

variable "extaudit_diag_logs" {
  description = "Detalhes da categoria de monitoramento de banco de dados para configuração de diagnóstico do Azure"
  default     = ["MariaDBSlowLogs", "MariaDBAuditLogs"]
}
