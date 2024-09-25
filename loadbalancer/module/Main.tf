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

  depends_on = [ azurerm_resource_group.example ]

}

module "lb" {
  source  = "./resources"
  resource_group_name = "tf-compute-dev-rg"
  location = "eastus"

  lb_configurations = {
    name    = "my-load-balancer-test"
    sku = "Gateway"
    sku_tier = "Regional"
    tags = {
      environment = "development"
    }
  }

  frontend_ip_configurations = {
    name       = "PublicIPAddress"
#    public_ip_address_id = "" # Escolha entre public_ip_address_id e subnet_id, não ambos # utilize somente com Sku tipo Gateway
    zones      = ["1", "2", "3"] # Utilize somente com a variável subnet_id preenchida
    private_ip_address = "10.0.0.4"
    subnet_id = "/subscriptions/93ebcf81-8118-4fb6-a4a7-de78cc2549e1/resourceGroups/tf-compute-dev-rg/providers/Microsoft.Network/virtualNetworks/tf-network-full-vnet/subnets/tf-network-full-vnet-public-subnet-1" # Utilize subnet ao invés de public_ip_address_id e não ambos
  }

  create_public_ip = true
  public_ip = {
    name                = "PublicIPForLB"
    allocation_method   = "Static"
    idle_timeout_in_minutes = 4
    ip_version = "IPv4"
    sku                = "Standard"
    sku_tier           = "Regional"

    tags = {
      environment = "development"
    }
  }

  create_lb_rule = true
  lb_rule = [ # Rules TCP não são permitidas para Lb tipo Gateway
  {
    name                           = "LBRule1"
    protocol                       = "All"
    frontend_port                  = 0
    backend_port                   = 0
    # backend_address_pool_ids       = [""]
  },
  #{
  #  name                           = "LBRule2"
  #  protocol                       = "Tcp"
  #  frontend_port                  = 3390
  #  backend_port                   = 3390
  #  # backend_address_pool_ids       = [""]
  #},
  #{
  #  name                           = "LBRule3"
  #  protocol                       = "Tcp"
  #  frontend_port                  = 3391
  #  backend_port                   = 3391
  #  # backend_address_pool_ids       = [""]
  #}
  ]

  create_lb_probe = true
  lb_probe = [{
    name            = "ssh-running-probe"
    port            = 22
  },
  {
    name            = "http-running-probe"
    port            = 80
  }]


  # Para utilizar este recurso, especifique um valor para a variável `backend_address_pool_id`
  create_lb_nat_rule = false
  nat_rule = [{
    name                           = "RDPAccess"
    protocol                       = "Tcp"
    frontend_port_start            = 3000
    frontend_port_end              = 3389
    backend_port                   = 3389
    enable_floating_ip             = true
    enable_tcp_reset               = true
    backend_address_pool_id        = ""
  }]

  # Lb tipo Gateway não suporta este recurso.
  create_lb_nat_pool = false
  nat_pool = [{
    name                           = "SampleApplicationPool"
    protocol                       = "Tcp"
    frontend_port_start            = 80
    frontend_port_end              = 81
    backend_port                   = 8080
    idle_timeout_in_minutes        = 4
    floating_ip_enabled            = true
    tcp_reset_enabled              = true
  }]

  # Para utilizar este recurso, especifique um valor para a variável `backend_address_pool_id`
  create_lb_outbound_rule = false
  outbound_rule = [{
    name                    = "OutboundRule"
    protocol                = "Tcp"
    idle_timeout_in_minutes = 10
    enable_tcp_reset        = true
    allocated_outbound_ports = 10024
    backend_address_pool_id        = ""
  }]

  frontend_nat_outbound_ip_configurations = [
    {
    name = "PublicIPAddress"
    },
    {
    name = "PublicIPAddress2IfYouHave"
    },
    ]  

 # Este recurso somente é permitido para lb tipo Gateway
  create_lb_backend_address_pool = true
  lb_backend_address_pool = [{
    name = "BackEndAddressPool"
    # synchronous_mode = "Automatic" # Essa variável somente é permitida com lb tipo Standard
    virtual_network_id = module.virtual_network_test.vnet_id
  }]

  tunnel_interface = [{
    identifier = 808 # 800 até 1000
    type = "External"
    protocol = "VXLAN"
    port = "8000"
  }]

  create_lb_backend_address_pool_address = false
  lb_backend_address_pool_address = [
   {
     name                    = "RefersIP"
     backend_address_pool_id = data.azurerm_lb_backend_address_pool.backend-pool-cr.id
     virtual_network_id      = module.virtual_network_test.vnet_id
     ip_address              = "10.0.5.1"
   },
  {
    name                    = "RefersBackEndAddressPoolId"
    backend_address_pool_id             = data.azurerm_lb_backend_address_pool.backend-pool-cr.id
    backend_address_ip_configuration_id =  data.azurerm_lb.example.frontend_ip_configuration[0].id
  }
  ]

}

data "azurerm_lb" "example" {
  name                = "my-load-balancer-test"
  resource_group_name = azurerm_resource_group.example.name
}


data "azurerm_lb_backend_address_pool" "backend-pool-cr" {
  name            = "BackEndAddressPool"
  loadbalancer_id = data.azurerm_lb.example.id
}