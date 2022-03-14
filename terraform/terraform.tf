terraform {
  
  required_version = ">= 0.12"
  # Lock down on the versions
  required_providers {
    aws        = "~> 3.0"
    kubernetes = "~> 1.9"
  }
  # This sets up the remote backend in terraform cloud mainly with two workspaces
  # `dev` and `prod`.
  # Workspace provides us the way to maintain multiple terraform states in remote
  # backend. It also provides a global name `terraform.workspace` that might be able to
  # differentiate resource in aws based on environment or workspace we are in.

  # backend "remote" {
  #   hostname = "app.terraform.io"
  #   # This needs to replaced by the organization that you create in terraform.io
  #   organization = "test-organization"
  #   # For multiple workspace support
  #   workspaces {
  #     prefix = "infrastructure-"
  #   }
  # }
}
