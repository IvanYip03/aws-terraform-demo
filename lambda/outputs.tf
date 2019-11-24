output "api_book_v1_lambda_arn" {
  description = "ARN of lambda function"
  value       = "${aws_lambda_function.hello_world_lambda.arn}"
}

output "api_book_v1_lambda_invoke_arn" {
  description = "Invoke ARN of lambda function for api gateway intergration"
  value       = "${aws_lambda_function.hello_world_lambda.invoke_arn}"
}

