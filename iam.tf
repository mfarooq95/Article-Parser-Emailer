# Create the IAM role for the Lambda function to operate
resource "aws_iam_role" "lambda_role" {
  name = "terraform_lambda_function_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Create Policy resource for the IAM role. Tie Policy resource to Policy Document data block below
resource "aws_iam_policy" "iam_policy_for_lambda" {
  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM policy for managing AWS lambda role"
  policy      = data.aws_iam_policy_document.iam_policy_for_lambda_func.json
}

# Create IAM Policy Document data block for the IAM role. Add all permissions to the statement
data "aws_iam_policy_document" "iam_policy_for_lambda_func" {
  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
  }
}

# Create Policy Attachement for Lambda function's IAM role
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}