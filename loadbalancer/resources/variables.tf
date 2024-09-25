variable "tenant_id" {
  description = "Tenant ID"
  type        = string
  default     = null
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
  default     = null
}

variable "location" {
  description = "Região do Azure"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
  default     = null
}

variable "create_public_ip" {
  description = "Se deve criar um public ip e usá-lo para attacha-lo no lb"
  default     = false
}

variable "create_lb_rule" {
  description = "Se deve criar uma rule e usá-lo para attacha-lo no lb"
  default     = false
}

variable "create_lb_probe" {
  description = "Se deve criar uma probe e usá-lo para attacha-lo no lb_rule"
  default     = false
}

variable "create_lb_nat_rule" {
  description = "Se deve criar uma Nat Rule e usá-lo para attacha-lo no lb"
  default     = false
}

variable "create_lb_nat_pool" {
  description = "Se deve criar uma Nat Pool e usá-lo para attacha-lo no lb"
  default     = false
}

variable "create_lb_outbound_rule" {
  description = "Se deve criar uma Outbound Rule e usá-lo para attacha-lo no lb"
  default     = false
}

variable "create_lb_backend_address_pool" {
  description = "Se deve criar uma Backend Address Pool e usá-lo para attacha-lo no outbound rule ou nat rule"
  default     = false
}

variable "create_lb_backend_address_pool_address" {
  description = "Se deve criar uma Backend Address Pool Address e usá-lo para attacha-lo no outbound rule ou nat rule"
  default     = false
}

variable "lb_configurations" {
  type = object({
    name = string
    edge_zone = optional(string)
    sku = optional(string)
    sku_tier = optional(string)
    tags = map(string)
  })
  default = null
  description = <<EOF
    Bloco de variáveis para criação do LoadBalancer
    name - (Obrigatório) Especifica o nome do Load Balancer. Alterar isso força a criação de um novo recurso.
    edge_zone - (Opcional) Especifica a Edge Zone dentro da Região do Azure onde esse Load Balancer deve existir. Alterar isso força a criação de um novo Load Balancer.
    sku - (Opcional) O SKU do Azure Load Balancer. Os valores aceitos são Basic, Standarde Gateway. O padrão é Basic. Alterar isso força a criação de um novo recurso.
    sku_tier - (Opcional) sku_tier- (Opcional) O nível SKU deste Load Balancer. Os valores possíveis são Globale Regional. O padrão é Regional. Alterar isso força a criação de um novo recurso.
    tags- (Opcional) Um mapeamento de tags para atribuir ao recurso.
  EOF
}

variable "frontend_ip_configurations" {
  type = object({
    name       = string
    zones      = list(string)
    private_ip_address = optional(string)
    public_ip_address_id = optional(string)
    subnet_id = optional(string)
    gateway_load_balancer_frontend_ip_configuration_id = optional(string)
    private_ip_address_allocation = optional(string)
    private_ip_address_version = optional(string)
    public_ip_prefix_id = optional(string)
  })
  description = <<EOF
  Configurações do IP frontal
    name - (Required) Specifies the name of the frontend IP configuration.
    zones - (Optional) Specifies a list of Availability Zones in which the IP Address for this Load Balancer should be located.
    subnet_id - (Optional) The ID of the Subnet which should be associated with the IP Configuration.
    gateway_load_balancer_frontend_ip_configuration_id - (Optional) The Frontend IP Configuration ID of a Gateway SKU Load Balancer.
    private_ip_address - (Optional) Private IP Address to assign to the Load Balancer. The last one and first four IPs in any range are reserved and cannot be manually assigned.
    private_ip_address_allocation - (Optional) The allocation method for the Private IP Address used by this Load Balancer. Possible values as Dynamic and Static.
    private_ip_address_version - (Optional) The version of IP that the Private IP Address is. Possible values are IPv4 or IPv6.
    public_ip_address_id - (Optional) The ID of a Public IP Address which should be associated with the Load Balancer.
    public_ip_prefix_id - (Optional) The ID of a Public IP Prefix which should be associated with the Load Balancer. Public IP Prefix can only be used with outbound rules.
  EOF
  default = null
}

variable "public_ip" {
  type = object({
    name                    = string
    allocation_method       = string
    idle_timeout_in_minutes = optional(number)
    zones                   = optional(list(string))
    ddos_protection_mode    = optional(string)
    ddos_protection_plan_id = optional(string)
    domain_name_label       = optional(string)
    edge_zone               = optional(string)
    ip_version              = optional(string, "IPv4")
    public_ip_prefix_id     = optional(string)
    reverse_fqdn            = optional(string)
    sku                     = optional(string)
    sku_tier                = optional(string)
    tags                    = optional(map(string))
  })
  default = null
  description = <<EOF
    Bloco de variáveis para Public IP
    name - (Obrigatório) Especifica o nome do IP público. Alterar isso força a criação de um novo IP público.
    allocation_method - (Obrigatório) Define o método de alocação para este endereço IP. Os valores possíveis são Staticou Dynamic.
    ddos_protection_mode - (Opcional) O modo de proteção DDoS do IP público. Os valores possíveis são Disabled, Enabled, e VirtualNetworkInherited. O padrão é VirtualNetworkInherited.
    ddos_protection_plan_id - (Opcional) O ID do plano de proteção DDoS associado ao IP público.
    domain_name_label - (Opcional) Rótulo para o Nome de Domínio. Será usado para compor o FQDN. Se um rótulo de nome de domínio for especificado, um registro DNS A será criado para o IP público no sistema DNS do Microsoft Azure.
    idle_timeout_in_minutes - (Opcional) Especifica o tempo limite para a conexão TCP ociosa. O valor pode ser definido entre 4 e 30 minutos.
    ip_version - (Opcional) A versão de IP a ser usada, IPv6 ou IPv4. Alterar isso força a criação de um novo recurso. O padrão é IPv4.
    public_ip_prefix_id - (Opcional) Se especificado, o endereço IP público alocado será fornecido a partir do recurso de prefixo IP público. Alterar isso força a criação de um novo recurso.
    reverse_fqdn - (Opcional) Um nome de domínio totalmente qualificado que resolve para este endereço IP público. Se o reverseFqdn for especificado, então um registro DNS PTR é criado apontando do endereço IP no domínio in-addr.arpa para o reverse FQDN.
    sku- (Opcional) O SKU do IP público. Os valores aceitos são Basice Standard. O padrão é Basic. Alterar isso força a criação de um novo recurso.
    sku_tier- (Opcional) O SKU Tier que deve ser usado para o IP público. Os valores possíveis são Regionale Global. O padrão é Regional. Alterar isso força a criação de um novo recurso.
  EOF
}

variable "lb_rule" {
  type = list(object({
    name = string
    protocol = string
    frontend_port = string
    backend_port = string
    backend_address_pool_ids = optional(list(string))
    idle_timeout_in_minutes = optional(number)
    enable_floating_ip = optional(bool)
    load_distribution = optional(string, "Default")
    disable_outbound_snat = optional(bool, false)
    enable_tcp_reset = optional(bool)
  }))
  default = []
  description = <<EOF
    Bloco de variáveis para Lb Rule
    name- (Obrigatório) Especifica o nome da Regra LB. Alterar isso força a criação de um novo recurso.
    protocol- (Obrigatório) O protocolo de transporte para o endpoint externo. Os valores possíveis são Tcp, Udpou All.
    frontend_port- (Obrigatório) A porta para o ponto de extremidade externo. Os números de porta para cada Regra devem ser exclusivos dentro do Balanceador de Carga. Os valores possíveis variam entre 0 e 65534, inclusive. Uma porta de 0significa "Qualquer Porta".
    backend_port- (Obrigatório) A porta usada para conexões internas no endpoint. Os valores possíveis variam entre 0 e 65535, inclusive. Uma porta 0significa "Qualquer Porta".
    backend_address_pool_ids- (Opcional) Uma lista de referências a um pool de endereços de backend sobre o qual esta regra de balanceamento de carga opera.
    enable_floating_ip- (Opcional) Os IPs flutuantes estão habilitados para esta regra do balanceador de carga? Um IP "flutuante" é reatribuído a um servidor secundário caso o servidor primário falhe. Obrigatório para configurar um SQL AlwaysOn Availability Group. O padrão é false.
    idle_timeout_in_minutes- (Opcional) Especifica o tempo limite de inatividade em minutos para conexões TCP. Os valores válidos estão entre 4e 100minutos. O padrão é 4minutos.
    load_distribution- (Opcional) Especifica o tipo de distribuição de balanceamento de carga a ser usado pelo Load Balancer. Os valores possíveis são: Default– O load balancer está configurado para usar um hash de 5 tuplas para mapear o tráfego para servidores disponíveis. SourceIP– O load balancer está configurado para usar um hash de 2 tuplas para mapear o tráfego para servidores disponíveis. SourceIPProtocol– O load balancer está configurado para usar um hash de 3 tuplas para mapear o tráfego para servidores disponíveis. Também conhecido como Session Persistence, onde no portal do Azure as opções são chamadas None, Client IPe Client IP and Protocolrespectivamente. O padrão é Default.
    disable_outbound_snat- (Opcional) O snat está habilitado para esta regra do balanceador de carga? Padrão false.
  EOF
}


variable "lb_probe" {
  type = list(object({
    name = string
    protocol = optional(string)
    port = optional(number)
    probe_threshold = optional(number)
    request_path = optional(string)
    interval_in_seconds = optional(string)
    number_of_probes = optional(number)
  }))
  default = []
  description = <<EOF
    Bloco de variáveis para Lb Probe
    name - (Obrigatório) Especifica o nome do Probe. Alterar isso força a criação de um novo recurso.
    protocol - (Opcional) Especifica o protocolo do ponto final. Os valores possíveis são Http, Httpsou Tcp. Se TCP for especificado, um ACK recebido será necessário para que a sonda seja bem-sucedida. Se HTTP for especificado, uma resposta 200 OK do URI especificado será necessária para que a sonda seja bem-sucedida. O padrão é Tcp.
    port - (Obrigatório) Porta na qual o Probe consulta o endpoint de backend. Os valores possíveis variam de 1 a 65535, inclusive.
    probe_threshold - (Opcional) O número de sondagens consecutivas bem-sucedidas ou com falha que permitem ou negam tráfego para este ponto final. Os valores possíveis variam de 1a 100. O valor padrão é 1.
    request_path - (Opcional) O URI usado para solicitar status de saúde do endpoint de backend. Obrigatório se o protocolo estiver definido como Httpou Https. Caso contrário, não é permitido.
    interval_in_seconds - (Opcional) O intervalo, em segundos, entre sondagens para o endpoint de backend para status de saúde. O valor padrão é 15, o valor mínimo é 5.
    number_of_probes - (Opcional) O número de tentativas de sondagem com falha após o qual o ponto de extremidade de backend é removido da rotação. Padrão para 2. NumberOfProbes multiplicado pelo valor intervalInSeconds deve ser maior ou igual a 10. Os pontos de extremidade são retornados à rotação quando pelo menos uma sondagem é bem-sucedida.
  EOF
}

variable "nat_rule" {
  type = list(object({
    name = string
    protocol = string
    frontend_port_start = optional(number)
    frontend_port_end = optional(number)
    backend_port = number
    idle_timeout_in_minutes = optional(number)
    enable_floating_ip = optional(bool, false)
    enable_tcp_reset = optional(bool)
    backend_address_pool_id = optional(string)
  }))
  default = []
  description = <<EOF
    Bloco de variáveis para Nat Rule
    name - (Obrigatório) Especifica o nome da Regra NAT. Alterar isso força a criação de um novo recurso.
    protocol - (Obrigatório) O protocolo de transporte para o endpoint externo. Os valores possíveis são Udp, Tcp ou All.
    frontend_port_start - (Opcional) O início do intervalo de portas para o ponto de extremidade externo. Esta propriedade é usada junto com BackendAddressPool e FrontendPortRangeEnd. Mapeamentos de porta de regra NAT de entrada individuais serão criados para cada endereço de backend do BackendAddressPool. Os valores aceitáveis ​​variam de 1 a 65534, inclusive.
    frontend_port_end - (Opcional) O fim do intervalo de portas para o endpoint externo. Esta propriedade é usada junto com BackendAddressPool e FrontendPortRangeStart. Mapeamentos de porta de regra NAT de entrada individuais serão criados para cada endereço de backend do BackendAddressPool. Os valores aceitáveis ​​variam de 1 a 65534, inclusive.
    backend_port - (Obrigatório) A porta usada para conexões internas no endpoint. Os valores possíveis variam entre 1 e 65535, inclusive.
    idle_timeout_in_minutes - (Opcional) Especifica o tempo limite de inatividade em minutos para conexões TCP. Os valores válidos estão entre 4e 30minutos. O padrão é 4minutos.
    enable_floating_ip - (Opcional) Os IPs flutuantes estão habilitados para esta regra do balanceador de carga? Um IP "flutuante" é reatribuído a um servidor secundário caso o servidor primário falhe. Obrigatório para configurar um SQL AlwaysOn Availability Group. O padrão é false.
    enable_tcp_reset - (Opcional) A redefinição de TCP está habilitada para esta regra do balanceador de carga?
    backend_address_pool_id - (Opcional) Especifica uma referência ao recurso backendAddressPool.
  EOF
}

variable "nat_pool" {
  type = list(object({
    name = string
    protocol = string
    frontend_port_start = optional(string)
    frontend_port_end = optional(string)
    backend_port = optional(string)
    idle_timeout_in_minutes = optional(number)
    floating_ip_enabled = optional(bool, false)
    tcp_reset_enabled = optional(bool)
  }))
  default = []
  description = <<EOF
    Bloco de variáveis para Nat Rule
    name - (Obrigatório) Especifica o nome do pool NAT. Alterar isso força a criação de um novo recurso.
    protocol - (Obrigatório) O protocolo de transporte para o endpoint externo. Os valores possíveis são Udp, Tcp ou All.
    frontend_port_start - (Opcional) O início do intervalo de portas para o ponto de extremidade externo. Esta propriedade é usada junto com BackendAddressPool e FrontendPortRangeEnd. Mapeamentos de porta de regra NAT de entrada individuais serão criados para cada endereço de backend do BackendAddressPool. Os valores aceitáveis ​​variam de 1 a 65534, inclusive.
    frontend_port_end - (Opcional) O fim do intervalo de portas para o endpoint externo. Esta propriedade é usada junto com BackendAddressPool e FrontendPortRangeStart. Mapeamentos de porta de regra NAT de entrada individuais serão criados para cada endereço de backend do BackendAddressPool. Os valores aceitáveis ​​variam de 1 a 65534, inclusive.
    backend_port - (Obrigatório) A porta usada para conexões internas no endpoint. Os valores possíveis variam entre 1 e 65535, inclusive.
    idle_timeout_in_minutes - (Opcional) Especifica o tempo limite de inatividade em minutos para conexões TCP. Os valores válidos estão entre 4e 30minutos. O padrão é 4minutos.
    floating_ip_enabled - (Opcional) Os IPs flutuantes estão habilitados para esta Regra do Balanceador de Carga? Um IP flutuante é reatribuído a um servidor secundário caso o servidor primário falhe. Necessário para configurar um SQL AlwaysOn Availability Group.
    tcp_reset_enabled - (Opcional) A redefinição de TCP está habilitada para esta regra do balanceador de carga?
  EOF
}

variable "outbound_rule" {
  type = list(object({
    name                          = string
    protocol                      = string
    idle_timeout_in_minutes       = optional(number)
    backend_address_pool_id       = optional(string)
    enable_tcp_reset              = optional(bool)
    allocated_outbound_ports      = optional(number)
  }))
  default = null
  description = <<EOF
    Bloco de Variáveis para Outbound Rule
    name - (Obrigatório) Especifica o nome da Outbound Rule. Alterar isso força a criação de um novo recurso.
    protocol - (Obrigatório) O protocolo de transporte para o endpoint externo. Os valores possíveis são Udp, Tcpou All.
    idle_timeout_in_minutes - (Opcional) O tempo limite para a conexão TCP ociosa é definido como 4.
    backend_address_pool_id - (Obrigatório) O ID do Backend Address Pool. O tráfego de saída é balanceado aleatoriamente em IPs nos IPs de backend.
    enable_tcp_reset - (Opcional) Receber TCP Reset bidirecional em tempo limite de fluxo TCP ocioso ou término inesperado de conexão. Este elemento é usado somente quando o protocolo é definido como TCP.
    allocated_outbound_ports- (Opcional) O número de portas de saída a serem usadas para NAT. O padrão é 1024.
  EOF
}

variable "frontend_nat_outbound_ip_configurations" {
  type = list(object({
    name       = string
  }))
  description = <<EOF
  Configurações do IP frontal
    name - (Required) O nome da configuração de IP do frontend.
  EOF
  default = []
}

variable "lb_backend_address_pool" {
  type = list(object({
    name = string
    synchronous_mode = optional(string)
    virtual_network_id = optional(string)
  }))
  default = []
  description = <<EOF
    Bloco de variáveis para lb backend address pool
    name - (Obrigatório) Especifica o nome do Backend Address Pool. Alterar isso força a criação de um novo recurso.
    synchronous_mode - (Opcional) O modo síncrono de endereço de backend para o Backend Address Pool. Os valores possíveis são Automatic e Manual. Isso é necessário com virtual_network_id. Alterar isso força a criação de um novo recurso.
    O ID da rede virtual na qual o pool de endereços de backend deve existir.
  EOF
}

variable "tunnel_interface" {
  type        = list(object({
    identifier = number
    type = string
    protocol = string
    port = string
  }))
  description = <<EOF
  (Opcional) Um ou mais tunnel_interface blocos conforme definido abaixo.
  (Obrigatório) identifier - O identificador exclusivo desta Interface de Túnel do Gateway Load Balancer.
  (Obrigatório) type - O tipo de tráfego desta Gateway Load Balancer Tunnel Interface. Os valores possíveis são None, Internale External.
  (Obrigatório) protocol - O protocolo usado para esta Gateway Load Balancer Tunnel Interface. Os valores possíveis são None, Nativee VXLAN.
  (Obrigatório) port - O número da porta que esta Interface de Túnel do Balanceador de Carga do Gateway escuta.

  EOF
  default     = []
}

variable "lb_backend_address_pool_address" {
  type = list(object({
    name = string
    backend_address_pool_id = string
    backend_address_ip_configuration_id = optional(string)
    ip_address = optional(string)
    virtual_network_id = optional(string)
  }))
  default = []
  description = <<EOF
    Bloco de variáveis para blackend pool address ip
    name - (Obrigatório) O nome que deve ser usado para este Backend Address Pool Address. Alterar isso força a criação de um novo Backend Address Pool Address.
    backend_address_pool_id - (Obrigatório) O ID do Backend Address Pool. Alterar isso força a criação de um novo Backend Address Pool Address.
    backend_address_ip_configuration_id - (Opcional) O ID de configuração de IP do balanceador de carga regional que é adicionado ao pool de endereços de backend do balanceador de carga global.
    ip_address - (Opcional) O endereço IP estático que deve ser alocado para este pool de endereços de backend.
    virtual_network_id - (Opcional) O ID da rede virtual na qual o pool de endereços de backend deve existir.
  EOF
}