resource "aws_iam_role" "lambda" {
 name = "bedrock-lambda-role"
 assume_role_policy = jsonencode({
 Version = "2012-10-17"
 Statement = [{
 Action = "sts:AssumeRole"
 Effect = "Allow"
 Principal = { Service = "lambda.amazonaws.com" }
 }]
 })
 tags = { Project = "karatu-2025-capstone" }
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
 role = aws_iam_role.lambda.name
 policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "asset_processor" {
 function_name = "bedrock-asset-processor"
 role = aws_iam_role.lambda.arn
 handler = "index.handler"
 runtime = "python3.12"
 filename = "../lambda-src/function.zip"
 source_code_hash = filebase64sha256("../lambda-src/function.zip")
 tags = { Project = "karatu-2025-capstone" }
}

resource "aws_lambda_permission" "allow_s3" {
 statement_id = "AllowS3Invoke"
 action = "lambda:InvokeFunction"
 function_name = aws_lambda_function.asset_processor.function_name
 principal = "s3.amazonaws.com"
 source_arn = aws_s3_bucket.assets.arn
}

resource "aws_s3_bucket_notification" "assets_notify" {
 bucket = aws_s3_bucket.assets.id
 lambda_function {
 lambda_function_arn = aws_lambda_function.asset_processor.arn
 events = ["s3:ObjectCreated:*"]
 }
 depends_on = [aws_lambda_permission.allow_s3]
}
