# Manifest only, not a real root module -- see README.md "Pre-mirrored terraform providers".
terraform {
  required_version = "1.16.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.64.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.8.1"
    }
    github = {
      source  = "integrations/github"
      version = "6.13.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.9.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }
}
