terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws      = ">= 2.48"
  }
}

provider "aws" {
  region = "sa-east-1"
  profile = "default"
}