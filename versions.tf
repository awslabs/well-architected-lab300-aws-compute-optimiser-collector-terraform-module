
terraform {
  required_version = ">= 0.12"

  required_providers {
    aws      = "~> 2.65.0"
    archive  = "~> 1.3"
    external = "~> 1.2"
    null     = "~> 2.1"
    vault    = "~> 2.9"
  }
}
