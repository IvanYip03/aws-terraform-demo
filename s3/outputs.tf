output "lambda_demo_artifacts_id" {
  description = "Name of bucket"
  value       = "${aws_s3_bucket.lambda_demo_artifacts.id}"
}

output "lambda_demo_artifacts_arn" {
  description = "The ARN of bucket"
  value       = "${aws_s3_bucket.lambda_demo_artifacts.arn}"
}
