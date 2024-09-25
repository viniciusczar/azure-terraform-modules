locals {
  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
  dns_zone            = element(coalescelist(data.azurerm_dns_zone.this.*.name, azurerm_dns_zone.this.*.name, [""]), 0)

  records_inserts       = {for rs in var.records_inserts : rs.type => rs ...}
  a_records_inserts     = lookup(local.records_inserts, "A", [])
  caa_records_inserts     = lookup(local.records_inserts, "CAA", [])
  aaaa_records_inserts  = lookup(local.records_inserts, "AAAA", [])
  cname_records_inserts = lookup(local.records_inserts, "CNAME", [])
  mx_records_inserts    = lookup(local.records_inserts, "MX", [])
  ns_records_inserts    = lookup(local.records_inserts, "NS", [])
  ptr_records_inserts   = lookup(local.records_inserts, "PTR", [])
  srv_records_inserts   = lookup(local.records_inserts, "SRV", [])
  txt_records_inserts   = lookup(local.records_inserts, "TXT", [])

  cname_records = flatten([
    for rs in local.cname_records_inserts : [
      for r in rs.records : {
        name = rs.name
        type = rs.type
        ttl  = rs.ttl
        data = r
      }
    ]
  ])

  caa_records = flatten([
    for rs in local.caa_records_inserts : [
      for r in rs.records : {
        flags = rs.flags
        tag = rs.tag
        value = rs.value
        data = r
      }
    ]
  ])

  supported_record_types = {
    A     = true
    CAA   = true
    AAAA  = true
    CNAME = true
    MX    = true
    NS    = true
    PTR   = true
    SRV   = true
    TXT   = true
  }
  check_supported_types = [
    for rs in var.records_inserts : local.supported_record_types[rs.type]
  ]

}

# Criação ou seleção de grupo de recursos - O padrão é "false"

data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = lower(var.resource_group_name)
  location = var.location
  tags     = merge({ "ResourceName" = format("%s", var.resource_group_name) }, var.tags, )
}

data "azurerm_dns_zone" "this" {
  count = var.create_dns_zone ? 0 : 1
  resource_group_name = var.resource_group_name
  name                = var.dns_zone_name
}

resource "azurerm_dns_zone" "this" {
  count = var.create_dns_zone ? 1 : 0
  name                = var.dns_zone_name
  resource_group_name = local.resource_group_name
  tags = var.dns_zone_settings.tags
  
  dynamic "soa_record" {
    for_each = var.dns_zone_settings.soa_record != null ? [1] : [0]
    content {
      email = var.dns_zone_settings.soa_record
      host_name = var.dns_zone_settings.soa_record
      expire_time = var.dns_zone_settings.soa_record
      minimum_ttl = var.dns_zone_settings.soa_record
      retry_time = var.dns_zone_settings.soa_record
      serial_number = var.dns_zone_settings.soa_record
      ttl = var.dns_zone_settings.soa_record
      tags = var.dns_zone_settings.soa_record
    }
  }

}

resource "azurerm_dns_a_record" "this" {
  count = length(local.a_records_inserts)

  resource_group_name = local.resource_group_name
  zone_name           = local.dns_zone

  name    = coalesce(local.a_records_inserts[count.index].name, "@")
  ttl     = local.a_records_inserts[count.index].ttl
  records = local.a_records_inserts[count.index].records
}

resource "azurerm_dns_caa_record" "this" {
  count = length(local.caa_records)

  resource_group_name = local.resource_group_name
  zone_name           = local.dns_zone

  name    = coalesce(local.caa_records[count.index].name, "@")
  ttl     = local.caa_records[count.index].ttl

  dynamic "record" {
    for_each = caa_records[count.index].records
    content {
      flags = caa_records[count.index].records.flags
      tag   = caa_records[count.index].records.tag
      value = caa_records[count.index].records.value
    }
  }

}

resource "azurerm_dns_aaaa_record" "this" {
  count = length(local.aaaa_records_inserts)

  resource_group_name = local.resource_group_name
  zone_name           = local.dns_zone

  name    = coalesce(local.aaaa_records_inserts[count.index].name, "@")
  ttl     = local.aaaa_records_inserts[count.index].ttl
  records = local.aaaa_records_inserts[count.index].records
}

resource "azurerm_dns_cname_record" "this" {
  count = length(local.cname_records)

  resource_group_name = local.resource_group_name
  zone_name           = local.dns_zone

  name   = coalesce(local.cname_records[count.index].name, "@")
  ttl    = local.cname_records[count.index].ttl
  record = local.cname_records[count.index].data
}

resource "azurerm_dns_mx_record" "this" {
  count = length(local.mx_records_inserts)

  resource_group_name = local.resource_group_name
  zone_name           = local.dns_zone

  name = coalesce(local.mx_records_inserts[count.index].name, "@")
  ttl  = local.mx_records_inserts[count.index].ttl

  dynamic "record" {
    for_each = mx_records_inserts[count.index].records
    content {
      preference = split(record.value, " ")[0]
      exchange   = split(record.value, " ")[1]
    }
  }
}

resource "azurerm_dns_ns_record" "this" {
  count = length(local.ns_records_inserts)

  resource_group_name = local.resource_group_name
  zone_name           = local.dns_zone

  name    = coalesce(local.ns_records_inserts[count.index].name, "@")
  ttl     = local.ns_records_inserts[count.index].ttl
  records = local.ns_records_inserts[count.index].records
}

resource "azurerm_dns_ptr_record" "this" {
  count = length(local.ptr_records_inserts)

  resource_group_name = local.resource_group_name
  zone_name           = local.dns_zone

  name    = coalesce(local.ptr_records_inserts[count.index].name, "@")
  ttl     = local.ptr_records_inserts[count.index].ttl
  records = local.ptr_records_inserts[count.index].records
}

resource "azurerm_dns_srv_record" "this" {
  count = length(local.srv_records_inserts)

  resource_group_name = local.resource_group_name
  zone_name           = local.dns_zone

  name = coalesce(local.srv_records_inserts[count.index].name, "@")
  ttl  = local.srv_records_inserts[count.index].ttl

  dynamic "record" {
    for_each = srv_records_inserts[count.index].records
    content {
      priority = split(record.value, " ")[0]
      weight   = split(record.value, " ")[1]
      port     = split(record.value, " ")[2]
      target   = split(record.value, " ")[3]
    }
  }
}

resource "azurerm_dns_txt_record" "this" {
  count = length(local.txt_records_inserts)

  resource_group_name = local.resource_group_name
  zone_name           = local.dns_zone

  name = coalesce(local.txt_records_inserts[count.index].name, "@")
  ttl  = local.txt_records_inserts[count.index].ttl

  dynamic "record" {
    for_each = txt_records_inserts[count.index].records
    content {
      value = record.value
    }
  }
}