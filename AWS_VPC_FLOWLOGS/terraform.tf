terraform {
  required_version = ">=1.3.0"

  cloud {
    organization = "AWS-TF-GH-CODESPACE"
    workspaces {
      name = "aws-terraform-codespace"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {

    region = var.region
  
}

