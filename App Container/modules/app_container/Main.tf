### https://github.com/hashicorp/terraform-provider-azurerm/issues/25303 Link do Bug
module "app_container" {
  source = "./resources/app_container"

  # Por padrão, este módulo criará um grupo de recursos
  # forneça um nome para usar um grupo de recursos existente e defina o argumento 
  # para `create_resource_group = false` se você deseja um grupo de recursos existente. 
  # Se você usar o location do grupo de recursos existente, será o mesmo do existente.
  create_resource_group        = false
  resource_group_name          = "tf-compute-dev-rg"
  location                     = "eastus"
  container_app_environment_id = azurerm_container_app_environment.example.id

  container_app_configurations = {
    name          = "tf-app-container"
    revision_mode = "Single"

    tags = {
      "Name" = "Este é um Teste"
    }
  }

  min_replicas = 1
  max_replicas = 3

  container = {
    name   = "nginx"
    image  = "nginx:latest"
    cpu    = 0.25
    memory = "0.5Gi"
    command = [
      "/bin/sh",
    ]
    args = [
      "-c", "echo Hello World! > /usr/share/nginx/html/index.html"
    ]
    volume_mounts = [
      {
        name = "shared"
        path = "/usr/share/nginx/html"
      }
    ]
    environment_variables = [{
      name  = "API_PORT"
      value = "3000"
      },
      {
        name  = "Project-2"
        value = "Environment 2 Aqui"
    }]
    liveness_probe = {
      transport               = "HTTP"
      path                    = "/health"
      port                    = 80
      initial_delay           = 30
      interval_seconds        = 30
      timeout                 = 15
      failure_count_threshold = 3
      header = {
        name  = "Content-Type"
        value = "application/json"
      }
    }
  }

  ingress = {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 3000
  }

  traffic_weight = [
    {
      latest_revision = true
      percentage      = 100
      label           = "only"
      #revision_suffix = "abc"
    }
  ]
  ip_security_restrictions = [
    {
      name             = "ExampleIP"
      ip_address_range = "177.16.20.103",
      action           = "Allow",
      description      = "This is example"
    }
  ]

  secret = [
    {
      name  = "secretacr"
      value = "ACRPullTokenAqui123"
    }
  ]

  identity = {
    type = "SystemAssigned"
  }
  dapr = {
    app_id   = "nginx"
    app_port = 3000
  }
  registry = [
      {
        server               = "http://serverhost.com:4000"
        username             = "UserName"
        password_secret_name = "Password123"
      }
    ]

  # Para habilitar um domínio a ser attachado ao App Container utilize a variável `enable_app_custom_domain` como true
  # (Obrigatório) Certifique-se de informar o DNS em `dns_zone_name` e a zona possuídora em `dns_zone_name`.
  enable_app_custom_domain                 = false
  dns_zone_name                            = "zona_existente"
  dns_record                               = "record_existente"
  container_app_environment_certificate_id = "certificado_id_existente_aqui"


  # Adicionando TAGs aos seus recursos do Azure
  tags = {
    environment = "development"
  }

}