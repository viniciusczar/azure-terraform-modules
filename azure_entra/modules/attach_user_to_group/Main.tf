module "attach_user_to_group" {
  source = "./modules/attach_user_to_group/resources"
  groups = ["Grupo1", "Grupo2"]
  member_object_id = "dcbed76e-1c31-4876-b074-7c52838eb03b"
}
