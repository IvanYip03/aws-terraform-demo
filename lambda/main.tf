provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

terraform {
  required_version = "> 0.11.0"
  backend          "s3"             {}
}

data "terraform_remote_state" "s3" {
  backend = "s3"

  config = {
    bucket  = "terraform-${var.aws_region}-${var.aws_accountId}"
    key     = "s3/terraform.tfstate"
    region  = "${var.aws_region}"
    profile = "${var.aws_profile}"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_lambda_function" "hello_world_lambda" {
  function_name = "hello-world"

  s3_bucket = "${data.terraform_remote_state.s3.outputs.lambda_demo_artifacts_id}"
  s3_key = "lambda-java-demo-1.0.zip"
  
  role = "${aws_iam_role.iam_for_lambda.arn}"
  
  handler = "com.demo.HelloWorld::handleRequest"
  runtime = "java8"
  timeout = 60
}

resource "aws_cloudwatch_log_group" "hello_world_log_group" {
  name              = "/aws/lambda/hello-world"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs_policy" {
  role = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.hello_world_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_accountId}:*/*/*/*"
}