locals {
  domain_name = data.azuread_domains.default.domains.0.domain_name
}

resource "azuread_group" "group" {
  count = length(var.groups) > 0 ? length(var.groups) : 0
  display_name = element(var.groups, count.index).display_name
  security_enabled = element(var.groups, count.index).security_enabled
  administrative_unit_ids = element(var.groups, count.index).administrative_unit_ids # Não aceita valores null
  assignable_to_role      = element(var.groups, count.index).assignable_to_role
  auto_subscribe_new_members = element(var.groups, count.index).auto_subscribe_new_members  
  behaviors = element(var.groups, count.index).behaviors
  description = element(var.groups, count.index).description
  external_senders_allowed = element(var.groups, count.index).external_senders_allowed
  hide_from_address_lists = element(var.groups, count.index).hide_from_address_lists
  hide_from_outlook_clients = element(var.groups, count.index).hide_from_outlook_clients
  mail_enabled              = element(var.groups, count.index).mail_enabled
  mail_nickname             = element(var.groups, count.index).mail_nickname
  onpremises_group_type     = element(var.groups, count.index).onpremises_group_type
  prevent_duplicate_names   = element(var.groups, count.index).prevent_duplicate_names
  theme                     = element(var.groups, count.index).theme
  visibility                = element(var.groups, count.index).visibility
  writeback_enabled         = element(var.groups, count.index).writeback_enabled
  types                     = element(var.groups, count.index).types
  provisioning_options = element(var.groups, count.index).provisioning_options
  members =  var.dynamic_membership == null && element(var.groups, count.index).members != null ? element(var.groups, count.index).members : null

  dynamic "dynamic_membership" { # Caso utilize o block dynamic, não utilize a variável members # Obrigatório quando types for DynamicMembership
    for_each =  element(var.groups, count.index).members == null && element(var.groups, count.index).dynamic_membership != null ? [1] : []
    content {
      enabled = element(var.groups, count.index).dynamic_membership.enabled
      rule = element(var.groups, count.index).dynamic_membership.rule
    }
  }

  owners = element(var.groups, count.index).owners

  lifecycle {
    ignore_changes = [administrative_unit_ids]
  }

}
