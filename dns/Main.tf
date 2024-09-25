module "dns" {
  source = "./resources"

  # Por padrão, este módulo criará um grupo de recursos
  # forneça um nome para usar um grupo de recursos existente e defina o argumento 
  # para `create_resource_group = false` se você deseja um grupo de recursos existente. 
  # Se você usar o location do grupo de recursos existente, será o mesmo do existente.
  create_resource_group = false
  resource_group_name   = "tf-compute-dev-rg"
  location              = "eastus"

  # A criação de uma DNS Zone é false, do contrário, irá criar um recurso especificado em `dns_zone_name`.
  create_dns_zone = true
  dns_zone_name   = "example.com"
  dns_zone_settings = {
    soa_record = {
      email     = "devops@luby.software"
      host_name = "ns1-03.azure-dns.com."
      tags = {
        "env"   = "soa-example-env"
        "owner" = "devops"
      }
    }

  }

  records_inserts = [
    {
      name = "www"
      type = "A"
      ttl  = 3600
      records = [
        "192.0.2.56",
      ]
    },
#    {
#      name  = ""
#      type  = "CAA"
#      ttl   = 3600
#      flags = 0
#      tag   = "issue"
#      records = [
#        "example.com"
#      ]
#    },
#    {
#      name = ""
#      type = "MX"
#      ttl  = 3600
#      records = [
#        "1 mail1",
#        "5 mail2",
#        "5 mail3",
#      ]
#    },
#    {
#      name = ""
#      type = "TXT"
#      ttl  = 3600
#      records = [
#        "\"v=spf1 ip4:192.0.2.3 include:backoff.example.com -all\"",
#      ]
#    },
#    {
#      name = "_sip._tcp"
#      type = "SRV"
#      ttl  = 3600
#      records = [
#        "10 60 5060 sip1",
#        "10 20 5060 sip2",
#        "10 20 5060 sip3",
#        "20  0 5060 sip4",
#      ]
#    },
  ]

  # Adicionando TAGs aos seus recursos do Azure
  tags = {
    environment = "development"
  }

}