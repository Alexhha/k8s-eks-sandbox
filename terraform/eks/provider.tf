provider "aws" {
    region  = var.region
    profile = "default"
}

terraform {
    required_version = "~> 1.4.6"

    required_providers {
        aws      = "~> 5.37"
        random   = "~> 3.5"
        null     = "~> 3.2"
        template = "~> 2.2"
    }
}
