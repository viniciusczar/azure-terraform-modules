locals {
  domain_name = data.azuread_domains.default.domains.0.domain_name
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*-_=+:?"
}

resource "null_resource" "export_password" {
  count = (var.path_export_credentials != null) ? 1 : 0

  provisioner "local-exec" {

    environment = {
      user     = lower("${var.user_configs.given_name}.${var.user_configs.surname}@${local.domain_name}")
      password = random_password.password.result
    }

    command = "echo $user \\ $password >> ${var.path_export_credentials}/$user.txt"
  }

  depends_on = [
    azuread_user.user
  ]
}


resource "azuread_user" "user" {
  
  user_principal_name         = "${lower(var.user_configs.given_name)}.${lower(var.user_configs.surname)}@${local.domain_name}"

  display_name               = "${var.user_configs.given_name} ${var.user_configs.surname}"
  mail_nickname              = "${lower(var.user_configs.given_name)}.${lower(var.user_configs.surname)}"
  given_name                 = var.user_configs.given_name
  job_title                  = var.user_configs.job_title
  password                   = random_password.password.result
  force_password_change      = var.user_configs.force_password_change
  disable_password_expiration= var.user_configs.disable_password_expiration
  disable_strong_password    = var.user_configs.disable_password_expiration
  account_enabled            = var.user_configs.account_enabled
  age_group                  = var.user_configs.consent_provided_for_minor != null ? var.user_configs.age_group : "Adult"
  business_phones            = var.user_configs.business_phones
  city                       = var.user_configs.city
  company_name               = var.user_configs.company_name
  consent_provided_for_minor = var.user_configs.consent_provided_for_minor
  cost_center                = var.user_configs.cost_center
  country                    = var.user_configs.country
  department                 = var.user_configs.department
  division                   = var.user_configs.division
  employee_id                = var.user_configs.employee_id
  employee_type              = var.user_configs.employee_type
  fax_number                 = var.user_configs.fax_number
  mail                       = var.user_configs.mail
  manager_id                 = var.user_configs.manager_id
  mobile_phone               = var.user_configs.mobile_phone
  office_location            = var.user_configs.office_location
  onpremises_immutable_id    = var.user_configs.onpremises_immutable_id
  other_mails                = var.user_configs.other_mails
  postal_code                = var.user_configs.postal_code
  preferred_language         = var.user_configs.preferred_language
  show_in_address_list       = var.user_configs.show_in_address_list
  state                      = var.user_configs.state
  street_address             = var.user_configs.street_address
  surname                    = var.user_configs.surname
  usage_location             = var.user_configs.usage_location
}