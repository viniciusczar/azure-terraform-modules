module "application-gateway" {
  source  = "./resources"

  # Por padrão, a criação de resource group é 'false'. Informe o nome de grupo de recursos existente.
  # A localização será a mesma do RG existente. 
  # defina o argumento como `create_resource_group = true` para criar um novo recurso.
  resource_group_name  = azurerm_resource_group.example.name
  location             = "eastus"
  virtual_network_name = "tf-network-full-vnet"
  subnet_name          = "tf-network-full-vnet-public-subnet-1"
  app_gateway_name     = "tf-testgateway"

  # SKU requer `name`, `tier` para usar neste Gateway de Aplicativo
  # A propriedade `Capacity` é opcional se `autoscale_configuration` estiver definido
  sku = {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  # Um pool de back-end encaminha a solicitação para servidores de back-end, que atendem a solicitação.
  # Pode criar diferentes pools de back-end para diferentes tipos de solicitações:
  backend_address_pools = [
    {
      name  = "tf-testgateway-bapool01"
      fqdns = ["example1.com", "example2.com"]
    },
    {
      name         = "tf-testgateway-bapool02"
      ip_addresses = ["1.2.3.4", "2.3.4.5"]
    }
  ]


  # Um gateway de aplicativo roteia o tráfego para os servidores back-end usando a porta, o protocolo e outras configurações
  # A porta e o protocolo usados ​​para verificar o tráfego são criptografados entre o gateway do aplicativo e os servidores backend
  # A lista de configurações HTTP de back-end pode ser adicionada aqui.  
  # O argumento `probe_name` é necessário se você estiver definindo sondagens de integridade.
  backend_http_settings = [
    {
      name                  = "tf-testgateway-be-http-set1"
      cookie_based_affinity = "Disabled"
      path                  = "/"
      enable_https          = false
      request_timeout       = 30
      # probe_name            = "tf-testgateway-probe1" # Remova isto se o objeto `health_probes` não estiver definido.
      connection_draining = {
        enable_connection_draining = true
        drain_timeout_sec          = 300

      }
    },
    {
      name                  = "tf-testgateway-be-http-set2"
      cookie_based_affinity = "Enabled"
      path                  = "/"
      enable_https          = false
      request_timeout       = 30
    }
  ]

  # Lista de ouvintes HTTP/HTTPS. O nome do certificado SSL é obrigatório
  # `Basic` - Este tipo de listener escuta um único site de domínio, onde possui um único mapeamento DNS para o endereço IP do gateway de aplicativo. Esta configuração de ouvinte é necessária quando você hospeda um único site atrás de um gateway de aplicativo.
  # `Multi-site` - Esta configuração do listener é necessária quando você deseja configurar o roteamento com base no nome do host ou nome de domínio para mais de um aplicativo Web no mesmo gateway de aplicativo. Cada site pode ser direcionado para seu próprio pool de back-end.
  # Definir o valor `host_name` altera o tipo de ouvinte para 'Multi site`. `host_names` permite caracteres curinga especiais.
  http_listeners = [
    {
      name      = "tf-testgateway-be-htln01"
      host_name = null
    }
  ]

  # A regra de roteamento de solicitação serve para determinar como rotear o tráfego no ouvinte. 
  # A regra vincula o ouvinte, o pool de servidores de back-end e as configurações HTTP de back-end.
  # `Basic` - Todas as solicitações no ouvinte associado (por exemplo, blog.contoso.com/*) são encaminhadas para o ouvinte associado pool de back-end usando a configuração HTTP associada.
  # `Path-based` - Esta regra de roteamento permite rotear as solicitações no ouvinte associado para um pool de back-end específico, com base no URL da solicitação.
  # o nível de `priority` é obrigatório.
  request_routing_rules = [
    {
      name                       = "tf-testgateway-be-rqrt"
      rule_type                  = "Basic"
      http_listener_name         = "tf-testgateway-be-htln01"
      backend_address_pool_name  = "tf-testgateway-bapool01"
      backend_http_settings_name = "tf-testgateway-be-http-set1"
      priority                   = 1
    }
  ]

  # Uma lista com um único ID de identidade gerenciado pelo usuário a ser atribuído para acessar o Keyvault
  identity_ids = ["${azurerm_user_assigned_identity.example.id}"]

  # (Opcional) Para habilitar o Monitoramento do Azure para Gateway de Aplicativo do Azure
  # (Opcional) Especifique `storage_account_name` e `log_analytics_workspace_name` para salvar logs de monitoramento no armazenamento.
  # log_analytics_workspace_name = "loganalytics-we-sharedtest2"

  # Adicionando TAGs aos recursos do Azure
  tags = {
    ProjectName  = "tf-demo-internal"
    Env          = "dev"
  }
}