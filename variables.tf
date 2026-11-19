variable "slug" {
  type        = string
  description = "Stable OIDC provider slug. Maps to nomatron_oidc_provider.slug (required, RequiresReplace)."

  validation {
    condition     = length(trimspace(var.slug)) > 0
    error_message = "slug must be a non-empty string."
  }
}

variable "display_name" {
  type        = string
  description = "Human-readable provider name. Maps to nomatron_oidc_provider.display_name (required)."
}

variable "issuer_url" {
  type        = string
  description = "OIDC issuer URL. Maps to nomatron_oidc_provider.issuer_url (required)."
}

variable "client_id" {
  type        = string
  description = "OIDC client ID. Maps to nomatron_oidc_provider.client_id (required)."
}

variable "client_secret_wo" {
  type        = string
  default     = null
  sensitive   = true
  description = "OIDC client secret. Maps to nomatron_oidc_provider.client_secret_wo (optional, write-only, sensitive). Never stored in Terraform state. Omit if you are not setting or rotating the secret in this apply."
}

variable "scopes" {
  type        = list(string)
  default     = null
  description = "OIDC scopes requested during login. Maps to nomatron_oidc_provider.scopes (optional, computed list of string)."
}

variable "username_claim" {
  type        = string
  default     = null
  description = "Claim used for the Nomatron username. Maps to nomatron_oidc_provider.username_claim (optional, computed)."
}

variable "email_claim" {
  type        = string
  default     = null
  description = "Claim used for the user's email address. Maps to nomatron_oidc_provider.email_claim (optional, computed)."
}

variable "name_claim" {
  type        = string
  default     = null
  description = "Claim used for the display name. Maps to nomatron_oidc_provider.name_claim (optional, computed)."
}

variable "groups_claim" {
  type        = string
  default     = null
  description = "Claim containing external group values. Maps to nomatron_oidc_provider.groups_claim (optional, computed). Required in practice if you use group mappings; the provider does not enforce that."
}

variable "allowed_email_domains" {
  type        = list(string)
  default     = null
  description = "Optional allow-list of email domains permitted to authenticate through this provider. Maps to nomatron_oidc_provider.allowed_email_domains (optional list of string)."
}

variable "auto_provision" {
  type        = bool
  default     = null
  description = "Whether valid first-time OIDC logins auto-create Nomatron users. Maps to nomatron_oidc_provider.auto_provision (optional, computed). The provider has no schema default."
}

variable "sync_profile" {
  type        = bool
  default     = null
  description = "Whether profile fields are synchronized at login. Maps to nomatron_oidc_provider.sync_profile (optional, computed)."
}

variable "sync_groups" {
  type        = bool
  default     = null
  description = "Whether external group claims synchronize mapped RBAC assignments at login. Maps to nomatron_oidc_provider.sync_groups (optional, computed). Group mappings only take effect at the next sign-in when this is on."
}

variable "enabled" {
  type        = bool
  default     = null
  description = "Whether this provider can be used for login. Maps to nomatron_oidc_provider.enabled (optional, computed)."
}

variable "is_default" {
  type        = bool
  default     = null
  description = "Whether this provider is the default OIDC login provider. Maps to nomatron_oidc_provider.is_default (optional, computed)."
}

variable "roles" {
  type = map(object({
    description = optional(string)
    permissions = list(string)
  }))
  default     = {}
  description = <<-EOT
    Optional custom roles to create with nomatron_role. The map key is nomatron_role.name (required, RequiresReplace).
    permissions is a required list of permission strings (no wildcards in examples). description is optional.
    built_in and scope are computed; do not set them.
    Mappings may target these names or existing built-in role names. Do not use this map to try to manage a built-in role.
  EOT

  validation {
    condition = alltrue([
      for name, role in var.roles : length(trimspace(name)) > 0 && length(role.permissions) > 0
    ])
    error_message = "roles keys must be non-empty names, and permissions must be a non-empty list."
  }
}

variable "mappings" {
  type = map(object({
    external_group  = string
    role            = string
    domain          = optional(string)
    organization_id = optional(string)
    description     = optional(string)
    enabled         = optional(bool)
  }))
  default     = {}
  description = <<-EOT
    OIDC group mappings. The map key is a local handle.
    external_group is the IdP group claim value. role is a Nomatron role name (a built-in role or a key/name from var.roles).
    Set exactly one of domain or organization_id. domain must be the exact server form: global, or org:<uuid> (not organization:<uuid>, not a bare UUID). If organization_id is set, the module sets domain to format("org:%s", organization_id).
    description and enabled are optional. The provider marks provider_slug, external_group, role, domain, description, and enabled as RequiresReplace, and Update is not supported; any change replaces the mapping.
  EOT

  validation {
    condition = alltrue([
      for m in values(var.mappings) : (m.domain != null) != (m.organization_id != null)
    ])
    error_message = "Each mapping must set exactly one of domain or organization_id."
  }

  validation {
    condition = alltrue([
      for m in values(var.mappings) :
      m.domain == null || m.domain == "global" || can(regex("(?i)^org:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", m.domain))
    ])
    error_message = "mappings[*].domain must be global or org:<uuid>. Do not use organization:<uuid>, service-account forms, or a bare UUID."
  }

  validation {
    condition = alltrue([
      for m in values(var.mappings) :
      m.organization_id == null || can(regex("(?i)^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", m.organization_id))
    ])
    error_message = "mappings[*].organization_id must be a UUID when set."
  }
}
