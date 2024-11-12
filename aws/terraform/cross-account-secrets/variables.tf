variable "secrets_arn_list" {
  type        = list(string)
  description = "List of secrets arn that needs to be shared." 
}

variable "external_role_arn" {
  type        = string
  description = "Arn for the dex role accessing the secrets."
}

variable "kms_keys_id_list" {
  type        = list(string)
  description = "The list of kms keys ids, this is for allowing dex_external_role to decrypt the secrets. Every secret has an encryption key, make sure to list all of the respective secrets keys here."
}
