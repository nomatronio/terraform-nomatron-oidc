module "oidc" {
  source = "../../"

  slug             = "example-idp"
  display_name     = "Example Identity Provider"
  issuer_url       = "https://idp.example.com"
  client_id        = "nomatron-example"
  client_secret_wo = var.client_secret_wo
}
