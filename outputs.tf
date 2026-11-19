output "provider_id" {
  description = "OIDC provider ID."
  value       = nomatron_oidc_provider.this.id
}

output "provider_slug" {
  description = "OIDC provider slug."
  value       = nomatron_oidc_provider.this.slug
}

output "roles" {
  description = "Map of custom role name to id, built_in, and scope."
  value = {
    for k, r in nomatron_role.this : k => {
      id       = r.id
      name     = r.name
      built_in = r.built_in
      scope    = r.scope
    }
  }
}

output "mappings" {
  description = "Map of mapping key to id, provider_id, external_group, role, domain, and enabled."
  value = {
    for k, m in nomatron_oidc_group_mapping.this : k => {
      id             = m.id
      provider_id    = m.provider_id
      external_group = m.external_group
      role           = m.role
      domain         = m.domain
      enabled        = m.enabled
    }
  }
}
