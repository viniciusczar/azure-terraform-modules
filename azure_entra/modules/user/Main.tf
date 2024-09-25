module "user_ad" {
  source = "./resources"

  user_configs = {
    display_name               = "Vinicius Test"
    given_name                 = "Vinicius"
    job_title                  = "DevOps"
    force_password_change      = true
    disable_password_expiration= false
    disable_strong_password    = false
    account_enabled            = true
    age_group                  = "Adult"
    business_phones            = ["11111111111"]
    city                       = "São Paulo"
    company_name               = "Luby Software"
    country                    = "BR"
    department                 = "DevOps"
    employee_id                = "01"
    employee_type              = "Colaborador"
    mail                       = "vinicius.test@luby.com.br"
    surname                    = "Silva"
  }

}