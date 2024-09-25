
resource "azurerm_management_group" "mnt-grp" {
  name = var.management_group_name
}

resource "azurerm_role_management_policy" "main" {
  scope              = azurerm_management_group.mnt-grp.id
  role_definition_id = var.role_definition_id

  dynamic "eligible_assignment_rules" {
    for_each = var.eligible_assignment_rules != null ? {} : null
    content {
      expiration_required = var.eligible_assignment_rules.expiration_required
      expire_after        = var.eligible_assignment_rules.expire_after
    }
  }

  dynamic "active_assignment_rules" {
    for_each = var.active_assignment_rules != null ? {} : null
    content {
      expiration_required = active_assignment_rules.value.expiration_required
      expire_after        = active_assignment_rules.value.expire_after
      require_justification = active_assignment_rules.value.require_justification
      require_multifactor_authentication = active_assignment_rules.value.require_multifactor_authentication
      require_ticket_info = active_assignment_rules.value.require_ticket_info
    }
  }

  dynamic "activation_rules" {
    for_each = var.activation_rules != null ? {} : null
    content {
      maximum_duration = activation_rules.value.maximum_duration
      require_approval        = activation_rules.value.require_approval
      require_justification = activation_rules.value.require_justification
      require_multifactor_authentication = activation_rules.value.require_multifactor_authentication
      require_ticket_info = activation_rules.value.require_ticket_info
      required_conditional_access_authentication_context = activation_rules.value.required_conditional_access_authentication_context
      dynamic "approval_stage" {
        for_each = activation_rules.value.approval_stage
        content {
            dynamic "primary_approver" {
                for_each = approval_stage.value.primary_approver
                content {
                    object_id = activation_rules.value.primary_approver.object_id
                    type = activation_rules.value.primary_approver.type
                }
            }
        }
      }
    }
  }

  dynamic "notification_rules" {
    for_each = var.notification_rules != null ? {} : null
    content {
        dynamic "active_assignments" {
            for_each = notification_rules.value.active_assignments
            content {
                dynamic "admin_notifications" {
                    for_each = notification_rules.value.active_assignments.admin_notifications
                    content {
                        notification_level = notification_rules.value.active_assignments.notification_level
                        default_recipients = notification_rules.value.active_assignments.default_recipients
                        additional_recipients = notification_rules.value.active_assignments.additional_recipients
                    }
                }
                dynamic "approver_notifications" {
                    for_each = notification_rules.value.active_assignments.approver_notifications
                    content {
                        notification_level = notification_rules.value.active_assignments.notification_level
                        default_recipients = notification_rules.value.active_assignments.default_recipients
                        additional_recipients = notification_rules.value.active_assignments.additional_recipients
                    }
                }
                dynamic "assignee_notifications" {
                    for_each = notification_rules.value.active_assignments.assignee_notifications
                    content {
                        notification_level = notification_rules.value.active_assignments.notification_level
                        default_recipients = notification_rules.value.active_assignments.default_recipients
                        additional_recipients = notification_rules.value.active_assignments.additional_recipients
                    }
                }
            }
        }
        dynamic "eligible_activations" {
            for_each = notification_rules.value.eligible_activations
            content {
                dynamic "admin_notifications" {
                    for_each = notification_rules.value.eligible_activations.admin_notifications
                    content {
                        notification_level = notification_rules.value.eligible_activations.admin_notifications.notification_level
                        default_recipients = notification_rules.value.eligible_activations.admin_notifications.default_recipients
                        additional_recipients = notification_rules.value.eligible_activations.admin_notifications.additional_recipients
                    }
                }
                dynamic "approver_notifications" {
                    for_each = notification_rules.value.eligible_activations.approver_notifications
                    content {
                        notification_level = notification_rules.value.eligible_activations.admin_notifications.notification_level
                        default_recipients = notification_rules.value.eligible_activations.admin_notifications.default_recipients
                        additional_recipients = notification_rules.value.eligible_activations.admin_notifications.additional_recipients
                    }
                }
                dynamic "assignee_notifications" {
                    for_each = notification_rules.value.eligible_activations.assignee_notifications
                    content {
                        notification_level = notification_rules.value.eligible_activations.admin_notifications.notification_level
                        default_recipients = notification_rules.value.eligible_activations.admin_notifications.default_recipients
                        additional_recipients = notification_rules.value.eligible_activations.admin_notifications.additional_recipients
                    }
                }
            }
        }
        dynamic "eligible_assignments" {
            for_each = notification_rules.value.eligible_assignments
            content {
                dynamic "admin_notifications" {
                    for_each = notification_rules.value.eligible_assignments.admin_notifications
                    content {
                        notification_level = notification_rules.value.eligible_assignments.admin_notificationsnotification_level
                        default_recipients = notification_rules.value.eligible_assignments.admin_notificationsdefault_recipients
                        additional_recipients = notification_rules.value.eligible_assignments.admin_notificationsadditional_recipients
                    }
                }
                dynamic "approver_notifications" {
                    for_each = notification_rules.value.eligible_assignments.approver_notifications
                    content {
                        notification_level = notification_rules.value.eligible_assignments.admin_notificationsnotification_level
                        default_recipients = notification_rules.value.eligible_assignments.admin_notificationsdefault_recipients
                        additional_recipients = notification_rules.value.eligible_assignments.admin_notificationsadditional_recipients
                    }
                }
                dynamic "assignee_notifications" {
                    for_each = notification_rules.value.eligible_assignments.assignee_notifications
                    content {
                        notification_level = notification_rules.value.eligible_assignments.admin_notificationsnotification_level
                        default_recipients = notification_rules.value.eligible_assignments.admin_notificationsdefault_recipients
                        additional_recipients = notification_rules.value.eligible_assignments.admin_notificationsadditional_recipients
                    }
                }  
            }
        }
    }
  }

  depends_on = [ azurerm_management_group.mnt-grp ]
}