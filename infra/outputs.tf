output "data_lake_bucket" {
  value = aws_s3_bucket.data_lake.bucket
}

output "state_of_lambda_ingestion_triggering_rule" {
  value = aws_cloudwatch_event_rule.lambda_ingestion_cloudwatch_rule.state
}
