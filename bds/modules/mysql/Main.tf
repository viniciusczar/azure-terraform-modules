module "mysql-server" {
  source = "./resources/mysql"


  # Por padrão, este módulo criará um grupo de recursos
  # forneça um nome para usar um grupo de recursos existente e defina o argumento 
  # para `create_resource_group = false` se você deseja um grupo de recursos existente. 
  # Se você usar o location do grupo de recursos existente, será o mesmo do existente.
  create_resource_group = false
  resource_group_name   = "tf-compute-dev-rg"
  location              = "eastus"

  # Configurações do servidor e banco de dados MySQL
  mysqlserver_name = "tf-mysqldbsrv01"

  mysqlserver_settings = {
    sku_name   = "GP_Standard_D2ds_v4"
    version    = "8.0.21"
    # usuário administrador padrão `sqladmin` e pode ser especificado conforme a escolha aqui
    # por padrão uma senha aleatória será criada por este módulo, porém, é possível especificar uma senha aqui
    admin_username = "sqladmin"
    admin_password = "H@Sh1CoR3!"
    # Nome do banco de dados, conjunto de caracteres e argumentos de collation 
    database_name = "demomysqldb"
    charset       = "utf8"
    collation     = "utf8_unicode_ci"

    # Perfil de armazenamento e outros argumentos opcionais
    storage = {
      auto_grow_enabled = true
      io_scaling_enabled = true
      iops = 3000
      size_gb = 5
    }

    backup_retention_days             = 7
    geo_redundant_backup_enabled      = false

  }

  # Parâmetros do servidor MySQL
  # Mais informações em: https://docs.microsoft.com/en-us/azure/mysql/concepts-server-parameters
  mysql_configuration = {
    interactive_timeout = "600"
  }

  # Administrador AD para um servidor Azure MySQL
  # Permite definir um usuário ou grupo existente do AD como administrador para um servidor SQL do Azure
  # ad_admin_login_name = "firstname.lastname@example.com"

  # Criar User Assigned Identity para ser gerente administrador do Active Directory em um MySQL Flexible Server
  # Caso já possua o User, informe o nome na variável `ad_admin_login_name`
  create_user_assigned_identity = false
  #  user_assigned_identity_name   = "exampleUAI"

  # (Opcional) Para habilitar o monitoramento do Azure para o banco de dados Azure MySQL
  # (Opcional) Especifique `enable_logs_to_storage_account` para salvar logs de monitoramento no armazenamento.
  # Crie a conta de armazenamento necessária especificando a variável opcional `storage_account_name`. Somente permitido letras e números.
  log_analytics_workspace_already_exists = false
  log_analytics_workspace_name           = "tf-loganalytics-we-sharedtest2"
  enable_logs_to_storage_account         = false
  storage_account_name                   = "tfmysqllogdignostics"


  # Você poderá vincular uma subnet ao PostgreSQL Server utilizando a variável `delegated_subnet_name`, desde que a variável `public_network_access_enabled` seja false.
  # Outro fator importante: A subnet precisa ter a delegation "Microsoft.DBforPostgreSQL/flexibleServers" incluída a ela na vNet.
  # Caso ainda não a possua: preencha o prefixo CIDR de endereço válido `subnet_address_prefix` da vNet para criá-la.
  virtual_network_name    = "tf-network-full-vnet"
  delegated_subnet_name = "tf-network-full-vnet-public-subnet-1"
  # subnet_address_prefix = ["10.0.5.0/32"]

  # A criação Private Endpoint requer uma subnet, caso já a possua, preencha `delegated_subnet_name` e `virtual_network_name` com subnet e vNet válidos.
  # Habilite com true a variável enable_private_dns_zone_endpoint para utilizar este recurso.
  # Para usar uma zona DNS privada existente, especifique a variável `create_private_dns_zone_name` como false, do contrário irá criá-la. O Padrão é false.
  enable_private_dns_zone_endpoint = true
  create_private_dns_zone_name = true
  azurerm_private_dns_zone_name = "tf.privatelink.mysql.database.azure.co"

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