# Manifest only, not a real root module -- see README.md "Pre-mirrored terraform providers".
terraform {
  # keep in sync with .terraform-version
  required_version = "1.15.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.60.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.8.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.13.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.9.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }
}
