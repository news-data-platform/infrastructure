terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      project     = var.project_name
      environment = "production"
      owner       = "kyrylo"
    }
  }

  ignore_tags {
    keys = ["awsApplication"]
  }
}

resource "aws_s3_bucket" "data_lake" {
  bucket        = "${var.project_name}-data-lake"
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "data_lake_versioning" {
  bucket = aws_s3_bucket.data_lake.id
  versioning_configuration {
    status = "Enabled"
  }
}

# TODO: move to s3
data "archive_file" "lambda_ingestion" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_ingestion"
  output_path = "${path.module}/.terraform/lambda_ingestion.zip"
}

resource "aws_lambda_function" "lambda_ingestion" {
  function_name = "${var.project_name}-lambda-ingestion"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "main.handler"
  runtime       = "python3.12"

  filename         = data.archive_file.lambda_ingestion.output_path
  source_code_hash = data.archive_file.lambda_ingestion.output_base64sha256

  timeout     = 300
  memory_size = 256

  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.data_lake.bucket
      ENVIRONMENT    = "production"
    }
  }
}

resource "aws_cloudwatch_event_rule" "lambda_ingestion_cloudwatch_rule" {
  state = var.enabled ? "ENABLED" : "DISABLED"

  name                = "${var.project_name}-lambda-ingestion-cloudwatch-rule"
  schedule_expression = "rate(15 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_ingestion_cloudwatch_target" {
  rule      = aws_cloudwatch_event_rule.lambda_ingestion_cloudwatch_rule.name
  target_id = "lambda-ingestion-cloudwatch-target"
  arn       = aws_lambda_function.lambda_ingestion.arn
}

resource "aws_lambda_permission" "lambda_ingestion_cloudwatch_permission" {
  statement_id  = "AllowExecutionFromCloudWatchEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_ingestion.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_ingestion_cloudwatch_rule.arn
}
