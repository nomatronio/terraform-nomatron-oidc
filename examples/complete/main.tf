module "oidc" {
  source = "../../"

  slug             = "example-idp"
  display_name     = "Example Identity Provider"
  issuer_url       = "https://idp.example.com"
  client_id        = "nomatron-example"
  client_secret_wo = var.client_secret_wo
  scopes           = ["openid", "profile", "email", "groups"]
  username_claim   = "preferred_username"
  email_claim      = "email"
  name_claim       = "name"
  groups_claim     = "groups"
  sync_groups      = true

  roles = {
    role-inspector = {
      description = "Can read application jobs in the mapped organization."
      permissions = ["organization.app_jobs.read"]
    }
  }

  mappings = {
    platform-operators = {
      external_group = "platform-operators"
      role           = "security-auditor"
      domain         = "global"
      description    = "Map the global group to an existing built-in role."
      enabled        = true
    }
    tenant-operators = {
      external_group  = "tenant-operators"
      role            = "role-inspector"
      organization_id = "123e4567-e89b-12d3-a456-426614174000"
      description     = "Grant the custom role in one organization."
      enabled         = true
    }
  }
}
