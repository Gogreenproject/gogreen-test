terraform {
  cloud {
    organization = "GoGreen-project"

    workspaces {
      name = "GoGreen-project-workspace"
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

