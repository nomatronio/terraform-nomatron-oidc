# Basic OIDC provider example

This example configures one OIDC provider without group mappings. Supply the provider address and token with `TF_VAR_nomatron_address` and `TF_VAR_nomatron_token`, and supply the client secret with `TF_VAR_client_secret_wo`. For example, run `terraform plan` from this directory after exporting those variables. Do not put secrets in command-line flags or committed variable files.
