terraform {
  required_version = "~> 1.2.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27.0"
    }
  }
  backend "s3" {
    bucket = "terraform-tfstate"
    key    = "state/terraform.tfstate"
    region = "us-west-2"

    dynamodb_table = "terraform-tfstate"
    encrypt        = true
  }
}

provider "aws" {
  profile = "terraform"
  region  = "us-west-2"
}
