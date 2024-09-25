module "groups_ad" {
  source = "./modules/groups/resources"
  groups = [
    {
    display_name     = "RH"
    description = "RH groups"
    mail_enabled = false
    mail_nickname = "rh.dynamic"
    security_enabled = false
    owners = ["a0ebd575-0aa1-4b66-a1ea-ee339a0cb864"]
    types = ["DynamicMembership"]
    visibility = "Private"
    dynamic_membership = {
        enabled = true
        rule = "(user.accountEnabled -eq True) and (user.companyName -eq \"CompanyName\")"
        }
    },
    {
    display_name     = "Programadores"
    mail_enabled     = true
    mail_nickname    = "test.owner"
    security_enabled = true
    types            = ["Unified"]
    behaviors = [
            "SubscribeNewGroupMembers",
            "WelcomeEmailDisabled"
        ]
    },
    {
    display_name = "admins"
    mail_enabled     = true
    mail_nickname    = "admin.owner"
    security_enabled        = true
    prevent_duplicate_names = true
    types            = ["Unified"]
    members = [
        "a0ebd575-0aa1-4b66-a1ea-ee339a0cb864"
    ]
    }
    ]
}