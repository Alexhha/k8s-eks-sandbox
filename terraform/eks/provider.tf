provider "aws" {
    region  = var.region
    profile = "default"
}

terraform {
    required_version = "~> 1.8.1"

    required_providers {
        aws      = "~> 5.46"
        random   = "~> 3.6"
        null     = "~> 3.2"
    }
}
