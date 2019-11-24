remote_state {
  backend = "s3"

  config = {
    profile = "${local.aws_profile}"
    bucket = "terraform-${local.aws_region}-${local.aws_accountId}"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region = "${local.aws_region}"
    encrypt = true
    dynamodb_table = "terraform-demo-lock-table"
  }
}

locals {
    aws_profile = "ivan@admin"
    aws_region = "ap-east-1"
    aws_accountId = "575603824553"
    aws_azs_a = "ape1-az1"
    aws_azs_b = "ape1-azb"
}


inputs = {
    aws_profile = "${local.aws_profile}"
    aws_region = "${local.aws_region}"
    aws_accountId = "${local.aws_accountId}"
    aws_azs_a = "${local.aws_azs_a}"
    aws_azs_b = "${local.aws_azs_b}"
}
