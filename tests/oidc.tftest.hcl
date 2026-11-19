mock_provider "nomatron" {}

run "basic_provider_only" {
  command = apply

  variables {
    slug             = "example-idp"
    display_name     = "Example Identity Provider"
    issuer_url       = "https://idp.example.com"
    client_id        = "nomatron-example"
    client_secret_wo = "test-secret-placeholder"
  }

  assert {
    condition     = output.provider_slug == "example-idp"
    error_message = "The provider slug should match the configured value."
  }

  assert {
    condition     = length(output.roles) == 0 && length(output.mappings) == 0
    error_message = "The basic case should create no roles or mappings."
  }
}

run "complete_provider_roles_and_mappings" {
  command = apply

  variables {
    slug         = "example-idp-complete"
    display_name = "Example Identity Provider"
    issuer_url   = "https://idp.example.com"
    client_id    = "nomatron-example"
    sync_groups  = true

    roles = {
      application-operator = {
        permissions = ["organization.app_jobs.read"]
      }
    }

    mappings = {
      global-role = {
        external_group = "platform-operators"
        role           = "application-operator"
        domain         = "global"
      }
      organization-role = {
        external_group  = "tenant-operators"
        role            = "application-operator"
        organization_id = "123e4567-e89b-12d3-a456-426614174000"
      }
    }
  }

  assert {
    condition     = keys(output.roles) == ["application-operator"]
    error_message = "The custom role should use its name as the for_each key."
  }

  assert {
    condition     = keys(output.mappings) == ["global-role", "organization-role"]
    error_message = "Mappings should use their map keys, with organization_id converted to the org domain form."
  }

  assert {
    condition     = output.mappings["organization-role"].domain == "org:123e4567-e89b-12d3-a456-426614174000"
    error_message = "An organization ID should become an org:<uuid> mapping domain."
  }
}

run "rejects_mapping_with_both_domain_forms" {
  command = plan

  variables {
    slug         = "bad-both"
    display_name = "Example Identity Provider"
    issuer_url   = "https://idp.example.com"
    client_id    = "nomatron-example"
    mappings = {
      invalid = {
        external_group  = "operators"
        role            = "application-operator"
        domain          = "global"
        organization_id = "123e4567-e89b-12d3-a456-426614174000"
      }
    }
  }

  expect_failures = [var.mappings]
}

run "rejects_organization_domain_alias" {
  command = plan

  variables {
    slug         = "bad-organization"
    display_name = "Example Identity Provider"
    issuer_url   = "https://idp.example.com"
    client_id    = "nomatron-example"
    mappings = {
      invalid = {
        external_group = "operators"
        role           = "application-operator"
        domain         = "organization:123e4567-e89b-12d3-a456-426614174000"
      }
    }
  }

  expect_failures = [var.mappings]
}

run "rejects_bare_domain_uuid" {
  command = plan

  variables {
    slug         = "bad-bare-uuid"
    display_name = "Example Identity Provider"
    issuer_url   = "https://idp.example.com"
    client_id    = "nomatron-example"
    mappings = {
      invalid = {
        external_group = "operators"
        role           = "application-operator"
        domain         = "123e4567-e89b-12d3-a456-426614174000"
      }
    }
  }

  expect_failures = [var.mappings]
}

run "rejects_service_account_domain_alias" {
  command = plan

  variables {
    slug         = "bad-service-account"
    display_name = "Example Identity Provider"
    issuer_url   = "https://idp.example.com"
    client_id    = "nomatron-example"
    mappings = {
      invalid = {
        external_group = "operators"
        role           = "application-operator"
        domain         = "service-account:123e4567-e89b-12d3-a456-426614174000"
      }
    }
  }

  expect_failures = [var.mappings]
}
