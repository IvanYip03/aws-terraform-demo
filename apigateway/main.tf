provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

terraform {
  required_version = "> 0.11.0"
  backend          "s3"             {}
}

data "terraform_remote_state" "lambda" {
  backend = "s3"

  config = {
    bucket  = "terraform-${var.aws_region}-${var.aws_accountId}"
    key     = "lambda/terraform.tfstate"
    region  = "${var.aws_region}"
    profile = "${var.aws_profile}"
  }
}
resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "rest-api"
}

resource "aws_api_gateway_resource" "book_resource" {
   rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
   parent_id   = "${aws_api_gateway_rest_api.rest_api.root_resource_id}"
   path_part   = "book"
}

resource "aws_api_gateway_method" "book_get_method" {
   rest_api_id   = "${aws_api_gateway_rest_api.rest_api.id}"
   resource_id   = "${aws_api_gateway_resource.book_resource.id}"
   http_method   = "GET"
   authorization = "NONE"
 }

 resource "aws_api_gateway_integration" "book_get_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id             = "${aws_api_gateway_resource.book_resource.id}"
  http_method             = "${aws_api_gateway_method.book_get_method.http_method}"
  integration_http_method = "POST" #Lambda function can only be invoked via POST
  type                    = "AWS_PROXY"
  uri                     = "${data.terraform_remote_state.lambda.outputs.api_book_v1_lambda_invoke_arn}"
}
resource "aws_api_gateway_deployment" "book_test_deployment" {
   depends_on = [
     "aws_api_gateway_integration.book_get_integration"
   ]

   rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
   stage_name  = "test"
 }
