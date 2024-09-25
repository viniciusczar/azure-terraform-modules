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
  description = "O local/região para manter todos os recursos da sua rede. Para obter a lista de todos os locais com formato de tabela do Azure CLI, execute 'az account list-locations -o table'"
  default     = ""
}

variable "create_resource_group" {
  description = "Se deve criar um grupo de recursos e usá-lo para todos os recursos de rede. O valor default é `false`"
  default     = false
}

variable "create_dapr_component" {
  description = "Se deve criar um componente dapr para incluir ao app container environment. O valor default é `false`"
  default     = false
}

variable "enable_container_app_certificate" {
  description = "Valor booleano para habilitar certificate SSL para o app container. O valor default é `false`"
  default     = false
}

variable "enable_storage_share" {
  description = "Valor booleano para habilitar compartilhamento de arquivos em storage account. O valor default é `false`"
  default     = false
}

variable "enable_container_app_environment_domain" {
  description = "Valor booleano para domain para o app environment. O valor default é `false`"
  default     = false
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
  default     = null
}

variable "dapr" {
      type = object({
      app_id       = string
      app_port     = number
      app_protocol = optional(string)
    })
    default = null
}

variable "app_container_certificate_configurations" {
  type = object({
    name                         = string
    container_app_environment_id = string
    certificate_base64           = string
    password                     = string
  })
  default     = null
  description = <<EOF
    name - (Obrigatório) O nome do Container Apps Environment Certificate. Alterar isso força a criação de um novo recurso.
    container_app_environment_id - (Obrigatório) O Container App Managed Environment ID para configurar este Certificado. Alterar isso força a criação de um novo recurso.
    certificate_base64 - (Obrigatório) A Chave Privada do Certificado como um PFX ou PEM codificado em base64. Alterar isso força a criação de um novo recurso.
    password - (Obrigatório) A senha para o Certificado. Alterar isso força a criação de um novo recurso.
  EOF
}

variable "container_app_environment_custom_domain" {
  type = object({
    certificate_base64 = string
    password           = string
    dns_suffix         = string
  })
  default     = null
  description = <<EOF
  certificate_base64 - (Required) The bundle of Private Key and Certificate for the Custom DNS Suffix as a base64 encoded PFX or PEM.
  password - (Required) The password for the Certificate bundle.
  dns_suffix - (Required) Custom DNS Suffix for the Container App Environment.
  EOF
}

variable "app_environment_configuration" {
  type = object({
    name                                        = string
    dapr_application_insights_connection_string = optional(string)
    infrastructure_resource_group_name          = optional(string, null)
    infrastructure_subnet_id                    = optional(string, null)
    internal_load_balancer_enabled              = optional(bool, null)
    zone_redundancy_enabled                     = optional(bool, null)
    log_analytics_workspace_id                  = optional(string)
    mutual_tls_enabled                          = optional(bool, false)
    tags                                        = optional(map(string))
  })
  default     = null
  description = <<EOF
  name - (Obrigatório) O nome do Container Apps Managed Environment. Alterar isso força a criação de um novo recurso.
  dapr_application_insights_connection_string - (Opcional) String de conexão do Application Insights usada pelo Dapr para exportar telemetria de comunicação de Serviço para Serviço. Alterar isso força a criação de um novo recurso.
  infrastructure_resource_group_name - (Opcional) Nome do grupo de recursos gerenciados pela plataforma criado para o Ambiente Gerenciado para hospedar recursos de infraestrutura. Alterar isso força a criação de um novo recurso.
  infrastructure_subnet_id - (Opcional) A Subnet existente a ser usada para o Container Apps Control Plane. Alterar isso força a criação de um novo recurso.
  internal_load_balancer_enabled - (Opcional) O Container Environment deve operar no Internal Load Balancing Mode? O padrão é false. Alterar isso força a criação de um novo recurso.
  zone_redundancy_enabled - (Opcional) O Container App Environment deve ser criado com Zone Redundancy habilitado? O padrão é false. Alterar isso força a criação de um novo recurso.
  log_analytics_workspace_id - (Opcional) O ID do Log Analytics Workspace para vincular este Container Apps Managed Environment. Alterar isso força a criação de um novo recurso.
  mutual_tls_enabled - (Opcional) A segurança da camada de transporte mútuo (mTLS) deve ser habilitada? O padrão é false.
  tags - (Opcional) Um mapeamento de tags para atribuir ao recurso.
  EOF
}

variable "workload_profile" {
  type = object({
    name                  = string
    workload_profile_type = string
    maximum_count         = string
    minimum_count         = string
  })
  default     = null
  description = <<EOF
    workload_profile - (Opcional) O perfil da carga de trabalho para escopo da execução do aplicativo de contêiner. Um workload_profilebloco conforme definido abaixo.
    name - (Obrigatório) O nome do perfil de carga de trabalho.
    workload_profile_type - (Obrigatório) Tipo de perfil de carga de trabalho para as cargas de trabalho a serem executadas. Os valores possíveis incluem Consumption, D4, D8, D16, D32, E4, E8, E16e E32.
    maximum_count - (Obrigatório) O número máximo de instâncias do perfil de carga de trabalho que podem ser implantadas no Container App Environment.
    minimum_count - (Obrigatório) O número mínimo de instâncias do perfil de carga de trabalho que podem ser implantadas no Container App Environment.
  EOF
}

variable "key_vault_name" {
  description = "O nome do key vault"
  default     = ""
}

variable "key_vault_id" {
  description = "O ID do key vault"
  default     = ""
}

variable "storage_account_name" {
  description = "O nome da conta de armazenamento para compartilhamento de arquivos"
  default     = null
}

variable "storage_settings" {
  type = object({
    name         = string
    share_name   = string
    access_mode  = string
    account_name = string
    primary_access_key = string
  })
  default     = null
  description = "(Opcional) Gerencia um armazenamento de ambiente de aplicativo de contêiner, gravando arquivos nesse compartilhamento de arquivos para tornar os dados acessíveis por outros sistemas."
}

variable "dapr_components" {
  type = list(object({
    name           = string
    component_type = string
    version        = string
    ignore_errors  = optional(bool, false)
    init_timeout   = optional(string)
    metadata = list(object({
      name        = string
      secret_name = optional(string)
      value       = optional(string)
    }))
    scopes = optional(list(string))
    secret = optional(list(object({
      name  = string
      value = string
    })))
  }))
  default     = null
  description = <<EOF
  name - (Obrigatório) O nome para este componente Dapr. Alterar isso força a criação de um novo recurso.
  component_type - (Obrigatório) O Tipo de Componente Dapr. Por exemplo state.azure.blobstorage. Alterar isso força a criação de um novo recurso.
  version - (Obrigatório) A versão do componente.
  ignore_errors - (Opcional) O sidecar do Dapr deve continuar a inicialização se o componente falhar ao carregar. O padrão éfalse
  init_timeout - (Opcional) O tempo limite para inicialização do componente como uma ISO8601string formatada. Por exemplo 5s, 2h, , 1m. O padrão é 5s.
  metadata - (Opcional) Um ou mais metadatablocos conforme detalhado abaixo.
    name - (Obrigatório) O nome do item de configuração de metadados.
    secret_name - (Opcional) O nome de um segredo especificado no secretsbloco que contém o valor para este item de configuração de metadados.
    value - (Opcional) O valor para este item de configuração de metadados.
  scopes - (Opcional) Uma lista de escopos aos quais este componente se aplica.
  secret - (Opcional) Um secretbloco conforme detalhado abaixo.
    name - (Obrigatório) O nome secreto.
    value - (Obrigatório) O valor deste segredo.
  EOF
}


variable "certificate_blob_base64" {
  description = "O pacote de Chave Privada e Certificado para o Sufixo DNS Personalizado como um PFX ou PEM codificado em base64."
  default     = ""
}

variable "certificate_password" {
  description = "A senha para o pacote de certificados."
  default     = ""
}

variable "dns_suffix" {
  description = "Sufixo DNS personalizado para o ambiente do aplicativo de contêiner."
  default     = ""
}

variable "dns_record" {
  description = "O nome do registro TXT do DNS."
  default     = ""
}

variable "dns_zone_name" {
  description = "Especifica a zona DNS onde o recurso existe."
  default     = ""
}

variable "tags" {
  description = "Um map de tags para adicionar a todos os recursos"
  type        = map(string)
  default     = {}
}
