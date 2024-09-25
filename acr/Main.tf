module "acr" {
  source = "./resources"

  # Por padrão, este módulo criará um grupo de recursos
  # forneça um nome para usar um grupo de recursos existente e defina o argumento 
  # para `create_resource_group = false` se você deseja um grupo de recursos existente. 
  # Se você usar o location do grupo de recursos existente, será o mesmo do existente.
  create_resource_group = false
  resource_group_name   = "tf-compute-dev-rg"
  location              = "eastus"

  # Configuração do Registro de Contêiner do Azure
  # O SKU `Classic` está obsoleto e não estará mais disponível para novos recursos
  container_registry_config = {
    name          = "containerregistrydemoproject01"
    admin_enabled = true
    sku           = "Premium"
    public_network_access_enabled = true
    quarantine_policy_enabled       = false
    zone_redundancy_enabled         = false
  }

  # As georreplicações só são suportadas em novos recursos com o SKU Premium.
  # A lista de georeplicações não pode conter o local onde existe o Container Registry.
  georeplications = [
    {
      location                = "northeurope"
      zone_redundancy_enabled = true
    },
    {
      location                = "francecentral"
      zone_redundancy_enabled = true
    },
    {
      location                = "uksouth"
      zone_redundancy_enabled = true
    }
  ]

  # identity_ids = var.user_assigned_identity_client_id

  # Com Key Vault existente, preencha os dados abaixo para utilizar os recursos de Encryptação
  # encryption = {
  #   key_vault_key_id   = "key_vault_key_id"
  #   identity_client_id = "identity_client_id"
  # }

  # Defina uma política de retenção com cuidado - os dados de imagem excluídos são irrecuperáveis.
  # Uma política de retenção para manifestos não marcados é atualmente um recurso de visualização dos registros de contêineres Premium
  # A política de retenção se aplica apenas a manifestos não marcados com carimbos de data/hora depois que a política é habilitada. O padrão é `7` dias.
  retention_policy = {
    days    = 10
    enabled = true
  }

  # A confiança de conteúdo é uma característica do nível de serviço Premium do Azure Container Registry.
  enable_content_trust = true

  # A criação de endpoint privado requer nome de VNet e prefixo de endereço para criar uma sub-rede
  # Para usar a zona DNS privada existente, especifique `existente_private_dns_zone` com um nome de zona válido
  enable_private_endpoint       = true
  virtual_network_name          = "tf-network-full-vnet"
  azurerm_private_dns_zone_name = "myregistry.privatelink.azurecr.io"
  existing_subnet_id               = "/subscriptions/93ebcf81-8118-4fb6-a4a7-de78cc2549e1/resourceGroups/tf-compute-dev-rg/providers/Microsoft.Network/virtualNetworks/tf-network-full-vnet/subnets/tf-network-full-vnet-public-subnet-1"
  ## private_subnet_address_prefix = ["10.1.5.0/27"]
  ## existing_private_dns_zone     = "demo.example.com"

  # (Opcional) Para habilitar o monitoramento do Azure para banco de dados MySQL do Azure
  # (Opcional) Especifique `storage_account_name` para salvar logs de monitoramento no armazenamento.
  # log_analytics_workspace_name = "loganalytics-we-sharedtest2"
  # storage_account_name = "storage_account_name"


  # Adicionando TAGs aos seus recursos do Azure
  tags = {
    environment = "development"
  }

}