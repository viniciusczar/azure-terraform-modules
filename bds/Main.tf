resource "azurerm_resource_group" "example" {
  name     = "tf-compute-dev-rg"
  location = "East US"
}

module "virtual_network_test" {
  source = "web-virtua-azure-multi-account-modules/vnet-full/azurerm"

  name                = "tf-network-full-vnet"
  resource_group_name = "tf-compute-dev-rg"
  ip_adresses         = ["10.0.0.0/16"]

  public_subnets = [
    {
      address_prefixes = ["10.0.1.0/24"]
    },
    {
      address_prefixes = ["10.0.2.0/24"]
      delegation = {
        name            = "tf-public-subnet-2-delegation"
        service_name    = "Microsoft.Web/serverFarms"
        service_actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    },
    {
      address_prefixes = ["10.0.10.0/24"]
    },
  ]

  private_subnets = [
    {
      address_prefixes = ["10.0.3.0/24"]
    },
    {
      address_prefixes = ["10.0.4.0/24"]
    },
  ]

  depends_on = [azurerm_resource_group.example]

}

module "mssql-server" {
  source = "./resources/mssql"


  # Por padrão, este módulo criará um grupo de recursos
  # forneça um nome para usar um grupo de recursos existente e defina o argumento 
  # para `create_resource_group = false` se você deseja um grupo de recursos existente. 
  # Se você usar o location do grupo de recursos existente, será o mesmo do existente.
  create_resource_group = false
  resource_group_name   = "tf-compute-dev-rg"
  location              = "eastus"

  # Detalhes do SQL Server e do banco de dados
  # O nome válido do objetivo de serviço para o banco de dados inclui S0, S1, S2, S3, P1, P2, P4, P6, P11
  sqlserver_name               = "tf-sqldbserver01-luby"
  database_name                = "demomssqldb"
  sql_database_edition         = "Standard"
  sqldb_service_objective_name = "S1"
  mssql_version                = "12.0"

  # O padrão da política de auditoria estendida do SQL Server é `true`. 
  # Para desativar, defina enable_sql_server_extended_auditing_policy como `false`  
  # A política de auditoria estendida do banco de dados é padronizada como `false`. 
  # para ativar, defina a variável `enable_database_extended_auditing_policy` como `true` 
  # Para habilitar o Azure Defender para banco de dados, defina `enable_threat_detection_policy` como true
  enable_threat_detection_policy = true
  log_retention_days             = 30

  # Shcedulle de notificações de varredura para os administradores de assinatura
  # Gerencie a avaliação de vulnerabilidade e defina `enable_vulnerability_assessment` como `true`
  enable_vulnerability_assessment = false
  email_addresses_for_alerts      = ["user@example.com", "firstname.lastname@example.com"]

  # A criação de endpoint privado requer nome de VNet e prefixo de endereço para criar uma sub-rede 
  # Para usar a zona DNS privada existente, especifique `existente_private_dns_zone` com um nome de zona válido
  enable_private_endpoint       = true
  virtual_network_name          = "tf-network-full-vnet"
  # private_subnet_address_prefix = ["10.0.5.0/32"]
  #existing_vnet_id        = ""
  existing_subnet_id      = "/subscriptions/93ebcf81-8118-4fb6-a4a7-de78cc2549e1/resourceGroups/tf-compute-dev-rg/providers/Microsoft.Network/virtualNetworks/tf-network-full-vnet/subnets/tf-network-full-vnet-public-subnet-1"
  azurerm_private_dns_zone_name = "tf.privatelink.database.windows.net"
  ## existing_private_dns_zone = "demo.example.com"


  # Administrador AD para um servidor SQL do Azure
  # Permite definir um usuário ou grupo como administrador do AD para um servidor SQL do Azure
  ad_admin_login_name = "firstname.lastname@example.com"

  # (Opcional) Para habilitar o monitoramento do Azure para banco de dados SQL do Azure, incluindo logs de auditoria
  # É necessário o ID do recurso do workspace de trabalho do Log Analytics
  # (Opcional) Especifique `storage_account_id` para salvar logs de monitoramento no armazenamento.
  # enable_log_monitoring      = true
  # log_analytics_workspace_id = "STRING_LOG_ANALYTICS_WORKSPACE_ID"

  # Criação de grupo de failover SQL. Requer entradade de secondary location.
  # enable_failover_group         = true
  # secondary_sql_server_location = "northeurope"


  # Regras de firewall para permitir clientes Azure e externos e endereços/intervalos IP específicos.
  enable_firewall_rules = true
  firewall_rules = [
    {
      name             = "access-to-azure"
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    },
    {
      name             = "desktop-ip"
      start_ip_address = "49.204.225.49"
      end_ip_address   = "49.204.225.49"
    }
  ]

  # Adicionar TAGs adicionais aos recursos do Azure
  tags = {
    ProjectName  = "demo-project"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}