# Terraform provider init
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = [""]
}

# Create Lambda function resource
resource "aws_lambda_function" "terraform_lambda_func" {
  filename         = "my_lambda_function.zip"
  function_name    = "from_the_margin"
  role             = aws_iam_role.lambda_role.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.12"
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  source_code_hash = filebase64sha256("my_lambda_function.zip")
  layers           = [aws_lambda_layer_version.python-feedparser-layer.arn]
  timeout          = 60
}

# Create Eventbridge Rule resource
resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "every_day"
  description         = "Fire the lambda once a day"
  schedule_expression = "rate(1 day)"
}

# Create Eventbridge Target resource. Target the eventbridge rule and then target the lambda function
resource "aws_cloudwatch_event_target" "run_lambda_every_day" {
  rule      = aws_cloudwatch_event_rule.every_day.name
  target_id = "terraform_lambda_func"
  arn       = aws_lambda_function.terraform_lambda_func.arn
}

# Create Lambda Permission for Cloudwatch and assign it
resource "aws_lambda_permission" "allow_cloudwatch_to_call_terraform_lambda_func" {
  statement_id  = "AllowExecutionFromCloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_lambda_func.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_day.arn
}

# Outputs
output "terraform_aws_role_output" {
  value = aws_iam_role.lambda_role.name
}

output "terraform_aws_role_arn_output" {
  value = aws_iam_role.lambda_role.arn
}
output "terraform_logging_arn_output" {
  value = aws_iam_policy.iam_policy_for_lambda.arn
}