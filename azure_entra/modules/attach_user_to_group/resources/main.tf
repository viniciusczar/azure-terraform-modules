data "azuread_groups" "grps" {
  count = length(var.groups) > 0 ? 1 : 0
  display_names = var.groups
}

resource "azuread_group_member" "attach_user_to_group" {
  for_each = data.azuread_groups.grps[0].object_ids != null ? { for k, v in data.azuread_groups.grps[0].object_ids : k => v if v != null } : {}
  group_object_id    = each.value
  member_object_id      = var.member_object_id
}

