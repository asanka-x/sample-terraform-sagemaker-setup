terraform {
  cloud {

    organization = "SourcedLearning"

    workspaces {
      name = "sample-terraform-sagemaker-setup"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.64.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.region
}