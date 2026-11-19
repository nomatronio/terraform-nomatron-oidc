output "provider_slug" {
  value       = module.oidc.provider_slug
  description = "Configured OIDC provider slug."
}

output "custom_roles" {
  value       = module.oidc.roles
  description = "Created custom roles."
}

output "group_mappings" {
  value       = module.oidc.mappings
  description = "Created IdP group mappings."
}
