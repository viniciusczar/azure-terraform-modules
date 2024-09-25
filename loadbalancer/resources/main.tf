resource "azurerm_lb" "main" {
  name                = var.lb_configurations.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.lb_configurations.sku
  edge_zone           = var.lb_configurations.edge_zone
  sku_tier            = var.lb_configurations.sku_tier

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configurations != null ? [1] : []
    content {
        name                 = var.frontend_ip_configurations.name
        zones                = var.frontend_ip_configurations.zones
        public_ip_address_id = var.frontend_ip_configurations.public_ip_address_id
        subnet_id            = var.frontend_ip_configurations.subnet_id
        gateway_load_balancer_frontend_ip_configuration_id = var.frontend_ip_configurations.gateway_load_balancer_frontend_ip_configuration_id
        private_ip_address = var.frontend_ip_configurations.private_ip_address
        private_ip_address_allocation = var.frontend_ip_configurations.private_ip_address_allocation
        private_ip_address_version = var.frontend_ip_configurations.private_ip_address_version
        public_ip_prefix_id = var.frontend_ip_configurations.public_ip_prefix_id
    }
  }

  tags                         = merge({ "Name" = format("%s", var.lb_configurations.name) }, var.lb_configurations.tags, )

}

# Criação de Public IP --- O padrão é "false"

resource "azurerm_public_ip" "pbi-1" {
  count                                   = var.create_public_ip ? 1 : 0
  name                = var.public_ip.name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip.allocation_method
  idle_timeout_in_minutes = var.public_ip.idle_timeout_in_minutes
  zones               = var.frontend_ip_configurations.zones
  ddos_protection_mode  = var.public_ip.ddos_protection_mode
  ddos_protection_plan_id = var.public_ip.ddos_protection_plan_id
  domain_name_label = var.public_ip.domain_name_label
  edge_zone         = var.lb_configurations.edge_zone != null ? var.lb_configurations.edge_zone : null
  ip_version        = var.public_ip.ip_version
  public_ip_prefix_id = var.public_ip.public_ip_prefix_id
  reverse_fqdn      = var.public_ip.reverse_fqdn
  sku               = var.public_ip.sku
  sku_tier          = var.public_ip.sku_tier
  tags = var.public_ip.tags
}

# Criação de Lb Rule --- O padrão é "false"

resource "azurerm_lb_rule" "rule-1" {
  count                                   = var.create_lb_rule && length(var.lb_rule) > 0 ? length(var.lb_rule) : 0
  loadbalancer_id = azurerm_lb.main.id
  name                           = element(var.lb_rule, count.index).name
  frontend_ip_configuration_name = var.frontend_ip_configurations.name
  protocol                       = element(var.lb_rule, count.index).protocol
  frontend_port                  = element(var.lb_rule, count.index).frontend_port
  backend_port                   = element(var.lb_rule, count.index).backend_port
  backend_address_pool_ids       = element(var.lb_rule, count.index).backend_address_pool_ids
  idle_timeout_in_minutes        = element(var.lb_rule, count.index).idle_timeout_in_minutes
  enable_floating_ip            = element(var.lb_rule, count.index).enable_floating_ip
  probe_id       = var.create_lb_probe ? azurerm_lb_probe.probe[0].id : null
  load_distribution            = element(var.lb_rule, count.index).load_distribution
  disable_outbound_snat         = element(var.lb_rule, count.index).disable_outbound_snat
  enable_tcp_reset              = element(var.lb_rule, count.index).enable_tcp_reset
}

# Criação de Lb Probe --- O padrão é "false"

resource "azurerm_lb_probe" "probe" {
  count                                   = var.create_lb_probe  && length(var.lb_probe) > 0 ? length(var.lb_probe) : 0
  loadbalancer_id = azurerm_lb.main.id
  name                           = element(var.lb_probe, count.index).name
  protocol                       = element(var.lb_probe, count.index).protocol
  port          = element(var.lb_probe, count.index).port
  probe_threshold = element(var.lb_probe, count.index).probe_threshold
  request_path = element(var.lb_probe, count.index).request_path
  interval_in_seconds = element(var.lb_probe, count.index).interval_in_seconds
  number_of_probes = element(var.lb_probe, count.index).number_of_probes
}

# Criação de Nat Rule --- O padrão é "false"

resource "azurerm_lb_nat_rule" "nat-rule" {
  count                                   = var.create_lb_nat_rule && length(var.nat_rule) > 0 ? length(var.nat_rule) : 0
  resource_group_name = var.resource_group_name
  loadbalancer_id = azurerm_lb.main.id
  name                           = element(var.nat_rule, count.index).name
  protocol                       = element(var.nat_rule, count.index).protocol
  frontend_port_start            = element(var.nat_rule, count.index).frontend_port_start
  frontend_port_end              = element(var.nat_rule, count.index).frontend_port_end
  backend_port                   = element(var.nat_rule, count.index).backend_port
  frontend_ip_configuration_name = var.frontend_ip_configurations.name
  idle_timeout_in_minutes        = element(var.nat_rule, count.index).idle_timeout_in_minutes
  enable_floating_ip            = element(var.nat_rule, count.index).enable_floating_ip
  backend_address_pool_id       = element(var.nat_rule, count.index).backend_address_pool_id
  enable_tcp_reset              = element(var.nat_rule, count.index).enable_tcp_reset

}

# Criação de Nat Pool --- O padrão é "false"

resource "azurerm_lb_nat_pool" "nat-pool" {
  count                                   = var.create_lb_nat_pool && length(var.nat_pool) > 0 ? length(var.nat_pool) : 0
  resource_group_name = var.resource_group_name
  loadbalancer_id = azurerm_lb.main.id
  name                           = element(var.nat_pool, count.index).name
  protocol                       = element(var.nat_pool, count.index).protocol
  frontend_port_start            = element(var.nat_pool, count.index).frontend_port_start
  frontend_port_end              = element(var.nat_pool, count.index).frontend_port_end
  backend_port                   = element(var.nat_pool, count.index).backend_port
  frontend_ip_configuration_name = var.frontend_ip_configurations.name
  idle_timeout_in_minutes        = element(var.nat_pool, count.index).idle_timeout_in_minutes
  floating_ip_enabled            = element(var.nat_pool, count.index).floating_ip_enabled
  tcp_reset_enabled              = element(var.nat_pool, count.index).tcp_reset_enabled

}

# Criação de OutBound Rule --- O padrão é "false"

resource "azurerm_lb_outbound_rule" "outbound-rule" {
  count                                   = var.create_lb_outbound_rule && length(var.outbound_rule) > 0 ? length(var.outbound_rule) : 0
  loadbalancer_id = azurerm_lb.main.id
  name                           = element(var.outbound_rule, count.index).name
  protocol                       = element(var.outbound_rule, count.index).protocol
  idle_timeout_in_minutes        = element(var.outbound_rule, count.index).idle_timeout_in_minutes
  backend_address_pool_id       = element(var.outbound_rule, count.index).backend_address_pool_id
  enable_tcp_reset              = element(var.outbound_rule, count.index).enable_tcp_reset
  allocated_outbound_ports      = element(var.outbound_rule, count.index).allocated_outbound_ports

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_nat_outbound_ip_configurations != null && var.create_lb_outbound_rule && length(var.outbound_rule) > 0 ? var.frontend_nat_outbound_ip_configurations : []
    content {
        name                 = var.frontend_nat_outbound_ip_configurations[0].name
    }
  }

}

# Criação de Backend Address Pool --- O padrão é "false"

resource "azurerm_lb_backend_address_pool" "bak-address-pool" {
  count                                   = var.create_lb_backend_address_pool && length(var.lb_backend_address_pool) > 0 ? length(var.lb_backend_address_pool) : 0
  loadbalancer_id = azurerm_lb.main.id
  name            = element(var.lb_backend_address_pool, count.index).name
  synchronous_mode = element(var.lb_backend_address_pool, count.index).synchronous_mode
  virtual_network_id = element(var.lb_backend_address_pool, count.index).virtual_network_id

  dynamic "tunnel_interface" {
    for_each = var.tunnel_interface != null && var.create_lb_backend_address_pool && length(var.lb_backend_address_pool) > 0 ? var.tunnel_interface : []
    content {
      identifier = var.tunnel_interface[0].identifier
      type       = var.tunnel_interface[0].type
      protocol = var.tunnel_interface[0].protocol
      port = var.tunnel_interface[0].port
    }
  }
}

# Criação de Backend Address Pool Addresses --- O padrão é "false"

resource "azurerm_lb_backend_address_pool_address" "addresses" {
  count                               = var.create_lb_backend_address_pool_address && length(var.lb_backend_address_pool_address) > 0 ? length(var.lb_backend_address_pool_address) : 0
  name                                = element(var.lb_backend_address_pool_address, count.index).name
  backend_address_pool_id             = azurerm_lb_backend_address_pool.bak-address-pool[0].id
  backend_address_ip_configuration_id = element(var.lb_backend_address_pool_address, count.index).ip_address == null ? azurerm_lb.main.frontend_ip_configuration[0].id : null
  virtual_network_id      = element(var.lb_backend_address_pool_address, count.index).virtual_network_id
  ip_address = element(var.lb_backend_address_pool_address, count.index).ip_address != null ? element(var.lb_backend_address_pool_address, count.index).ip_address : null
}