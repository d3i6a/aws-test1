terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.0.0-beta2"
    }
  }

  backend "s3" {
    bucket = "corp-dm-bk"
    key    = "corp-dm-bk/test-state-1"
    region = "us-east-1"
  }

}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}