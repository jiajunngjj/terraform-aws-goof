terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region                  = "ap-southeast-1"
  shared_credentials_file = "/Users/jiajun/.aws/credentials"
}

variable "bucket_name" {
  type    = string
  default = "jj-terraform-s3-goof-bucket"
}

variable "s3_acl" {
  type    = string
  default = "public-read-write"
}

resource "aws_s3_bucket" "jj-s3-bucket-iac-demo" {
  bucket = var.bucket_name
  acl    = var.s3_acl
}
