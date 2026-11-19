# Complete OIDC example

This example configures claims and Sync Groups, creates a custom role, maps `platform-operators` to the existing `security-auditor` built-in role in the global domain, and maps `tenant-operators` to the custom role in one organization. The organization UUID is formatted as `org:<uuid>`. The custom role uses `organization.app_jobs.read`, which applies only in the organization where that role is mapped.

Group mappings do not add users to organizations. Add membership separately. A mapping is applied to a user's roles at their next sign-in when Sync Groups is on. Changing a mapping replaces it. Supply credentials with `TF_VAR_nomatron_address`, `TF_VAR_nomatron_token`, and `TF_VAR_client_secret_wo`; use a secret manager or environment variables and never commit a real secret.
