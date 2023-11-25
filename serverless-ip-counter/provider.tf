terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "aorith" # Replace <CLI_PROFILE> with your AWS CLI profile name
  region  = var.region

  default_tags {
    tags = {
      Name = local.name
    }
  }
}
