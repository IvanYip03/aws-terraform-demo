provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

terraform {
  required_version = "> 0.11.0"
  backend          "s3"             {}
}

resource "aws_s3_bucket" "lambda_demo_artifacts" {
  bucket = "lambda-demo-artifacts"
  acl    = "private"
}

