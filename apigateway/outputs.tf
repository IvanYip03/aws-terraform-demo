output "base_url" {
  value = "${aws_api_gateway_deployment.book_test_deployment.invoke_url}"
}