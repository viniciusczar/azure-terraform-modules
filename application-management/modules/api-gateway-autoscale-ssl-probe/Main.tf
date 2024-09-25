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

  # Configuração de Autoscale (Opcional).
  autoscale_configuration = {
    min_capacity = 1
    max_capacity = 5
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
      ssl_certificate_name = "tf-testgateway-ssl01"
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

  # Terminação TLS (anteriormente conhecida como descarregamento de Secure Sockets Layer (SSL))
  # O certificado no ouvinte requer que toda a cadeia de certificados (certificado PFX) seja carregada para estabelecer a cadeia de confiança.
  # A autenticação e a configuração do certificado raiz confiável não são necessárias para serviços confiáveis ​​do Azure, como o Azure App Service.
  ssl_certificates = [{
    name     = "tf-testgateway-ssl01"
    data     = "./keyBag.pfx" # Certificado já deve estar gerado e em formato ".pfx".
    password = "P@$$w0rd123"
  }]

  # Por padrão, um gateway de aplicativo monitora a integridade de todos os recursos em seu pool de back-end e remove automaticamente os que não são íntegros.
  # Em seguida, ele monitora instâncias não íntegras e as adiciona de volta ao pool de back-end íntegro quando ficam disponíveis e respondem às sondagens de integridade.
  # deve permitir o tráfego de entrada da Internet nas portas TCP 65503-65534 para o SKU do Application Gateway v1 e nas portas TCP 65200-65535
  # para o SKU v2 com a sub-rede de destino como Qualquer e a origem como tag de serviço GatewayManager. Esta gama de portas é necessária para a comunicação da infraestrutura Azure.
  # Além disso, a conectividade de saída com a Internet não pode ser bloqueada e o tráfego de entrada proveniente da tag AzureLoadBalancer deve ser permitido.
  health_probes = [
    {
      name                = "tf-testgateway-probe1"
      host                = "127.0.0.1"
      interval            = 30
      path                = "/"
      port                = 443
      timeout             = 30
      unhealthy_threshold = 3
    }
  ]


  # Adicionando TAGs aos recursos do Azure
  tags = {
    ProjectName  = "tf-demo-internal"
    Env          = "dev"
  }
}