# Nomatron OIDC Terraform module

This module manages one OIDC provider, optional custom roles, and mappings from identity-provider group claim values to Nomatron roles. Group mappings are the supported way to grant roles from synchronized group membership.

Mappings take effect when a user next signs in, and only when Sync Groups is enabled. A mapping does not add the user to an organization; manage organization membership separately. Mapping changes replace the mapping resource.

## Requirements

- Terraform >= 1.11.0
- `nomatronio/nomatron` provider `~> 0.6`

The module does not configure the provider. Configure the root provider with your Nomatron server address and API token.

## Usage

```hcl
module "oidc" {
  source = "nomatronio/oidc/nomatron"

  slug             = "example-idp"
  display_name     = "Example Identity Provider"
  issuer_url       = "https://idp.example.com"
  client_id        = "nomatron-example"
  client_secret_wo = var.oidc_client_secret

  groups_claim = "groups"
  sync_groups  = true

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
    }
    tenant-operators = {
      external_group  = "tenant-operators"
      role            = "role-inspector"
      organization_id = "123e4567-e89b-12d3-a456-426614174000"
    }
  }
}
```

`domain` accepts `global` or `org:<uuid>`. The module also accepts `organization_id` and formats it as `org:<uuid>`. It rejects `organization:<uuid>`, a bare UUID, and other domain forms. The module requires custom role names to be non-empty, but it does not check whether they match built-in role names. Built-in roles can be mapping targets without being declared in `roles`.

Permissions with the `organization.*` prefix apply only in the organization where the role is mapped. In this example, `role-inspector` is mapped with `organization_id`; the global mapping uses the existing built-in `security-auditor` role instead.

Set the OIDC client secret using a secret manager or an environment variable such as `TF_VAR_oidc_client_secret`; pass it to `client_secret_wo`. The provider treats this as write-only, and the module never outputs it. Avoid placing secret values in command-line arguments or committed files. If you omit the value, the module does not set a client secret in that apply.

See [`examples/basic`](examples/basic) for provider-only configuration and [`examples/complete`](examples/complete) for custom roles and mappings.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `slug` | `string` | — | Stable OIDC provider slug. Changing it replaces the provider. |
| `display_name` | `string` | — | Human-readable provider name. |
| `issuer_url` | `string` | — | OIDC issuer URL. |
| `client_id` | `string` | — | OIDC client ID. |
| `client_secret_wo` | `string` | `null` | Sensitive, write-only client secret. Not stored in Terraform state. |
| `scopes` | `list(string)` | `null` | OIDC scopes requested during login. |
| `username_claim` | `string` | `null` | Claim used for the Nomatron username. |
| `email_claim` | `string` | `null` | Claim used for the user's email address. |
| `name_claim` | `string` | `null` | Claim used for the display name. |
| `groups_claim` | `string` | `null` | Claim containing external group values; required in practice for mappings. |
| `allowed_email_domains` | `list(string)` | `null` | Optional email-domain allow-list. |
| `auto_provision` | `bool` | `null` | Whether valid first-time OIDC logins auto-create Nomatron users. |
| `sync_profile` | `bool` | `null` | Whether profile fields are synchronized at login. |
| `sync_groups` | `bool` | `null` | Whether external group claims synchronize mapped role assignments at login. |
| `enabled` | `bool` | `null` | Whether this provider can be used for login. |
| `is_default` | `bool` | `null` | Whether this provider is the default OIDC login provider. |
| `roles` | `map(object({ description = optional(string), permissions = list(string) }))` | `{}` | Custom roles keyed by role name. `built_in` and `scope` are computed and are not configurable. |
| `mappings` | `map(object({ external_group = string, role = string, domain = optional(string), organization_id = optional(string), description = optional(string), enabled = optional(bool) }))` | `{}` | IdP group mappings keyed by a local handle. Exactly one of `domain` and `organization_id` is required. |

The provider has no schema defaults for optional OIDC settings. If omitted, the server supplies values; this module does not assert what those server values are.

## Outputs

| Name | Description |
| --- | --- |
| `provider_id` | OIDC provider ID. |
| `provider_slug` | OIDC provider slug. |
| `roles` | Map keyed by custom role name; each value contains `id`, `name`, `built_in`, and `scope`. |
| `mappings` | Map keyed by the mappings input key; each value contains `id`, `provider_id`, `external_group`, `role`, normalized `domain`, and `enabled`. |

## Importing existing resources

The import identifiers follow the provider implementation:

```shell
terraform import 'module.oidc.nomatron_oidc_provider.this' example-idp
terraform import 'module.oidc.nomatron_role.this["role-inspector"]' role-inspector
terraform import 'module.oidc.nomatron_oidc_group_mapping.this["tenant-operators"]' example-idp/<mapping-id>
```

The OIDC provider imports by slug, a custom role imports by name, and a mapping imports by `<provider_slug>/<mapping_id>`. Replace example resource and module addresses with the addresses in your configuration. Do not use a UUID for the OIDC provider import.

## Testing

Run the module's mock-provider tests and formatting checks from the repository root:

```shell
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform test
tflint
```

Install TFLint separately before running the final command. The tests use Terraform's mock Nomatron provider and do not contact a live Nomatron server.

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE).
