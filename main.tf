resource "nomatron_oidc_provider" "this" {
  slug                  = var.slug
  display_name          = var.display_name
  issuer_url            = var.issuer_url
  client_id             = var.client_id
  client_secret_wo      = var.client_secret_wo
  scopes                = var.scopes
  username_claim        = var.username_claim
  email_claim           = var.email_claim
  name_claim            = var.name_claim
  groups_claim          = var.groups_claim
  allowed_email_domains = var.allowed_email_domains
  auto_provision        = var.auto_provision
  sync_profile          = var.sync_profile
  sync_groups           = var.sync_groups
  enabled               = var.enabled
  is_default            = var.is_default
}

resource "nomatron_role" "this" {
  for_each = var.roles

  name        = each.key
  description = each.value.description
  permissions = each.value.permissions
}

resource "nomatron_oidc_group_mapping" "this" {
  for_each = var.mappings

  provider_slug  = nomatron_oidc_provider.this.slug
  external_group = each.value.external_group
  role           = contains(keys(var.roles), each.value.role) ? nomatron_role.this[each.value.role].name : each.value.role
  domain         = each.value.domain != null ? each.value.domain : format("org:%s", each.value.organization_id)
  description    = each.value.description
  enabled        = each.value.enabled
}
