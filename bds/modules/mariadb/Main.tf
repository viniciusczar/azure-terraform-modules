# Criação Interrompida https://learn.microsoft.com/en-us/azure/mariadb/whats-happening-to-mariadb
module "mariadb-server" {
  source = "./resources/mariadb"


  # Por padrão, este módulo criará um grupo de recursos
  # forneça um nome para usar um grupo de recursos existente e defina o argumento 
  # para `create_resource_group = false` se você deseja um grupo de recursos existente. 
  # Se você usar o local do grupo de recursos existente, será o mesmo do RG existente.
  create_resource_group = false
  resource_group_name   = "tf-compute-dev-rg"
  location              = "eastus"

  # Configurações do servidor e banco de dados MariaDB
  mariadb_server_name = "tf-mariadbsqlsrv01"

  mariadb_settings = {
    sku_name   = "GP_Gen5_16"
    storage_mb = 5120
    version    = "10.2"
    # usuário administrador padrão `sqladmin` e pode ser especificado conforme a escolha aqui
    # por padrão uma senha aleatória será criada por este módulo, porém, é possível especificar uma senha aqui
    admin_username = "sqladmin"
    admin_password = "H@Sh1CoR3!"
    # Nome do banco de dados, conjunto de caracteres e argumentos de collation 
    database_name = "demomariadb01"
    charset       = "utf8"
    collation     = "utf8_unicode_ci"
    # Perfil de armazenamento e outros argumentos opcionais
    auto_grow_enabled             = true
    backup_retention_days         = 7
    geo_redundant_backup_enabled  = false
    public_network_access_enabled = true
    ssl_enforcement_enabled       = true
  }

  # Define um valor de configuração MariaDB em um servidor MariaDB.
  # Mais informações em: https://mariadb.com/kb/en/server-system-variables/
  mariadb_configuration = {
    interactive_timeout = "600"
  }

  # Para utilizar Virtual Network service endpoints e rules:
  subnet_id = var.subnet_id

  # (Opcional) Para habilitar o monitoramento do Azure para o banco de dados Azure MariaDB
  # (Opcional) Especifique `enable_logs_to_storage_account` para salvar logs de monitoramento no armazenamento.
  # Crie a conta de armazenamento necessária especificando a variável opcional `storage_account_name`. Somente permitido letras e números.
  log_analytics_workspace_already_exists = false
  log_analytics_workspace_name           = "tf-loganalytics-we-sharedtest2"
  enable_logs_to_storage_account         = true
  storage_account_name                   = "tfmariadblogdignostics"

  # A criação Private Endpoint requer uma subnet privada, caso já a possua, preencha private_subnet_id com o ID da subnet privada, do contrário, preencha o prefixo CIDR de endereço válido `private_subnet_address_prefix` da vNet para criá-la.
  # Para usar a zona DNS privada existente, especifique a variável `existente_private_dns_zone` com um nome de zona válido
  enable_private_endpoint       = true
  virtual_network_name          = "tf-network-full-vnet"
  # private_subnet_address_prefix = ["10.0.5.0/32"]
  private_subnet_id             = "/subscriptions/93ebcf81-8118-4fb6-a4a7-de78cc2549e1/resourceGroups/tf-compute-dev-rg/providers/Microsoft.Network/virtualNetworks/tf-network-full-vnet/subnets/tf-network-full-vnet-private-subnet-1"
  azurerm_private_dns_zone_name = "tf.privatelink.mariadb.database.azure.com"
  #  existing_private_dns_zone     = "demo.example.com"

  # Regras de firewall para permitir clientes Azure e externos e endereços/intervalos IP específicos.
  firewall_rules = {
    access-to-azure = {
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    },
    desktop-ip = {
      start_ip_address = "49.204.228.223"
      end_ip_address   = "49.204.228.223"
    }
  }

  # Tags for Azure Resources
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
}