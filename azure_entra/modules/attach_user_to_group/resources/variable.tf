variable "groups" {
  type = list(string)
  default = []
  description = "Gerencia os grupos que serão attachados ao object user id"
}

variable "member_object_id" {
  type = string
  default = null
  description = "O ID do objeto do principal que você deseja adicionar como membro do grupo. Os tipos de objeto suportados são Usuários, Grupos ou Principais de Serviço. Alterar isso força a criação de um novo recurso."
}