
variable "sns_topic_arn" {}
variable "resource_name" {}
variable "dynamodb_arn" {}
variable "dynamodb_name" {}

locals{
  handler_name = "lambda_function.lambda_handler"
  lambda_source = "human-approval-helper"
  source_dir = "../../src"
  function_name = "human-approval-helper-${var.resource_name}"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current_region" {}



resource "aws_iam_policy" "lambda_policy" {
  policy  = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Action":[
            "sns:publish"
         ],
         "Effect":"Allow",
         "Resource":"${var.sns_topic_arn}"
      },
      {
         "Action":[
            "dynamodb:putItem",
            "dynamodb:getItem",
            "dynamodb:updateItem"

         ],
         "Effect":"Allow",
         "Resource":"${var.dynamodb_arn}"
      },
      {
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*",
        "Effect": "Allow"
      },
      {
        "Action": [
          "states:SendTaskSuccess"
        ],
        "Resource": "*",
        "Effect": "Allow"
      }


  ]
}

EOF
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name  = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${local.source_dir}/${local.lambda_source}/lambda_function.py"
  output_path = "lambda_function_payload.zip"
}

# AWS Lambda resources
resource "aws_lambda_function" "human_approval_helper" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = local.function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = local.handler_name

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.11"

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
      DYNAMO_DB_NAME = var.dynamodb_name
    }
  }
}

# module "lambda"  {
#   source  = "terraform-aws-modules/lambda/aws"
#   version = "6.5.0"

#   function_name = "human-approval-helper-${var.resource_name}"
#   handler       = local.handler_name
#   attach_policy = true
#   policy = aws_iam_policy.lambda_s3_policy.arn
#   runtime = "python3.11"
#   source_path = "${local.source_dir}/${local.lambda_source}"
#   environment_variables = {
#       API_URL = var.api_url
#       SNS_TOPIC_ARN = var.sns_topic_arn
#       DYNAMO_DB_NAME = var.dynamodb_name

#   }


    
# }

# outputs
output "lambda_function_arn" {
  value = "${aws_lambda_function.human_approval_helper.arn}"
}

output "lambda_invoke_arn" {
  value =  "${aws_lambda_function.human_approval_helper.invoke_arn}"
}

output "lambda_function_name" {
  value =  local.function_name
}
