resource "random_id" "stor" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    container_name = "Storage_Account_Name_Aqui"
  }

  byte_length = 8
}

module "app_container_environment" {
  source = "./resources/app_environment"

  # Por padrão, este módulo criará um grupo de recursos
  # forneça um nome para usar um grupo de recursos existente e defina o argumento 
  # para `create_resource_group = false` se você deseja um grupo de recursos existente. 
  # Se você usar o location do grupo de recursos existente, será o mesmo do existente.
  create_resource_group = false
  resource_group_name   = "tf-compute-dev-rg"
  location              = "eastus"

 # A utilização de subnets somente é permitida com CIDR final /21 ou inferior.
  app_environment_configuration = {
    name                     = "tf-devops-app-env"
    infrastructure_subnet_id = "/subscriptions/93ebcf81-8118-4fb6-a4a7-de78cc2549e1/resourceGroups/tf-compute-dev-rg/providers/Microsoft.Network/virtualNetworks/tf-network-full-vnet/subnets/tf-network-full-vnet-public-subnet-2"
  }

  # (Opcional) Para habilitar a criação de dapr componentes, especifique `create_dapr_component` como true.
  create_dapr_component = true
  dapr_components = [{
      name           = "statestore-${random_id.stor.hex}"
      component_type = "state.azure.blobstorage"
      version        = "v1"
      scopes         = ["nginx"]
      metadata = [
        {
          name  = "accountName"
          value = "Storage_Account_Name"
        },
        {
          name  = "containerName"
          value = "Storage_Container_Name"
        },
        {
          name  = "azureClientId"
          value = "User_Assigned_Identity_Id"
        }
      ]
  }]

  # (Opcional) Para habilitar o compartilhamento de arquivos por storage account defina `var.enable_storage_share` como true.
  # (Obrigatório) Em caso de `var.enable_storage_share`, defina o objeto `storage_settings` com os parâmetros do objeto.
  # (Opcional) Defina o objeto storage_settings com dados de uma storage account existente, exceto `name`, que pode ser descritivo.
  enable_storage_share = true
  storage_settings = {
    account_name = "stringstorageaccountaqui"
    share_name = "tf-app-container-example-files"
    access_mode = "ReadOnly"
    name         = "tfstordevopsappenv"
    primary_access_key = "AZUREPRIMARYKEY"
  }


  # (Opcional) Para habilitar domínios e certificados na environment do app container utilize `enable_container_app_environment_domain` como true
  # Preencha os valores com recursos existentes.
  #  enable_container_app_environment_domain = false
  #  certificate_blob_base64      = filebase64("testacc.pfx")
  #  certificate_password         = "TestAcc"
  #  dns_suffix                   = "acceptancetest.contoso.com"

}
