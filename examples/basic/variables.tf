variable "nomatron_address" {
  type        = string
  description = "Nomatron server address."
}

variable "nomatron_token" {
  type        = string
  sensitive   = true
  description = "Nomatron API token."
}

variable "client_secret_wo" {
  type        = string
  sensitive   = true
  description = "OIDC client secret supplied through TF_VAR_client_secret_wo."
}
