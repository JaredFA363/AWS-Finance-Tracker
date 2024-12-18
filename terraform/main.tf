provider "aws" {
    region = "us-east-1"
}

# S3 Bucket for Frontend
resource "aws_s3_bucket" "finance_app_bucket" {
    bucket = "finance-tracker-frontend${random_string.suffix.result}"
    acl    = "public-read"

    website {
        index_document = "index.html"
    }
} 

resource "random_string" "suffix" {
    length = 6
    special = false
}

# Dynamo Table for Records
resource "aws_dynamodb_table" "finance_table" {
    name         = "finance-records"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "id"

    attribute {
        name = "id"
        type = "S"
    } 
}

# Lambda Function
resource "aws_lambda_function" "finance_lambda" {
    function_name = "finance-tracker-lambda"
    runtime       = "nodejs16.x"
    handler       = "index.handler"
    filename      = "../backend/lambda_function_payload.zip"

    role = aws_iam_role.lambda_exec.arn
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
    name = "lambda-exec-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Action    = "sts:AssumeRole",
            Principle = { Service = "lambda.amazonaws.com" },
            Effect    = "Allow"
        }]
    })
}