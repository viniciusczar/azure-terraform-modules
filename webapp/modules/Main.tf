resource "azurerm_resource_group" "example" {
  name     = "tf-compute-dev-rg"
  location = "North Europe"
}

module "app-service" {
  source  = "./resources"

  # Por padrão, este módulo não criará um grupo de recursos. A localização será a mesma do RG existente.
  # forneça um nome para usar um grupo de recursos existente, especifique o nome do grupo de recursos existente, 
  # defina o argumento como `create_resource_group = true` para criar um novo grupo de recursos.
  resource_group_name = azurerm_resource_group.example.name

  # Configurações do plano de serviço de aplicativo e argumentos suportados. Nome padrão usado pelo módulo
  # Para especificar um nome personalizado, use `app_service_plan_name` com um nome válido.  
  # para planos de serviço, consulte https://azure.microsoft.com/en-us/pricing/details/app-service/windows/  
  # Plano de serviço de aplicativo para níveis `Free` ou `Shared` `use_32_bit_worker_process` deve ser definido como `true`.
  service_plan = {
    kind = "Linux"
    tier = "Standard"
    size = "S1"
  }


  # Configurações do serviço de aplicativo e argumentos suportados
  # Backup, connection_string, auth_settings, armazenamento para montagens são configurações opcionais
  app_service_name       = "tf-myapp-project"
  enable_client_affinity = true

  # Um bloco `site_config` para configurar o ambiente do aplicativo. 
  # Pilhas integradas disponíveis (windows_fx_version) para aplicativos da web `az webapp list-runtimes`
  # Pilhas de tempo de execução para aplicativos da web baseados em Linux (linux_fx_version) `az webapp list-runtimes --linux`
  site_config = {
    always_on                 = true
    dotnet_framework_version  = "v2.0"
    ftps_state                = "FtpsOnly"
    managed_pipeline_mode     = "Integrated"
  }

  # (Opcional) Um par de valores-chave de configurações do aplicativo
  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE       = "1"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
  }

  # O recurso Backup no Azure App Service cria facilmente backups de aplicativos manualmente ou de acordo com uma programação.
  # Você pode configurar os backups para serem retidos por um período de tempo indefinido.
  # Conta de armazenamento do Azure e contêiner na mesma assinatura do aplicativo do qual você deseja fazer backup. 
  # Especifique `storage_account_name` com um existente.
  # Este módulo cria um contêiner de armazenamento para manter todos os itens de backup. 
  # Itens de backup - configuração do aplicativo, conteúdo do arquivo, banco de dados conectado ao seu aplicativo
  enable_backup        = false
  storage_account_name = "stdiagfortesting1"
  
  backup_settings = {
    enabled                  = true
    name                     = "DefaultBackup"
    frequency_interval       = 1
    frequency_unit           = "Day"
    retention_period_in_days = 90
  }

  # Por padrão, o recurso App Insight é criado por este módulo. 
  # Especifique o ID de recurso válido para `application_insights_id` para usar o App Insight existente
  # Especifica o tipo de aplicativo configurando `application_insights_type` com string válida
  # Especifica o período de retenção em dias usando `retention_in_days`. Padrão 90.
  # Por padrão o IP real do cliente é mascarado nos logs, para habilitar configure `disable_ip_masking` como `true` 
  app_insights_name = "tf-log-insights-test"

  # Configuração de integração VNet regional
  # Permite colocar o back-end do aplicativo em uma sub-rede na rede virtual na mesma região
  # enable_vnet_integration = true
  # subnet_id               = "SUBNET_ID_AQUI"

  # Adding TAG's to your Azure resources 
  tags = {
    ProjectName  = "demo-devops"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "DevOps"
    ServiceClass = "Test"
  }
}