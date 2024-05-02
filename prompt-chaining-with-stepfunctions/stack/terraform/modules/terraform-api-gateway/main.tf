
data "aws_region" "current_region" {}
variable "resource_name" {}
variable "lambda_invoke_arn" {}
variable "lambda_function_name" {}

resource "aws_api_gateway_rest_api" "api" {
  name = var.resource_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  lifecycle {
  create_before_destroy = true
  }
}



########################################################################
### API methods and integrations begins###########
########################################################################


resource "aws_api_gateway_resource" "review" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "review"
  rest_api_id = aws_api_gateway_rest_api.api.id
}
########################################################################
### This is a code sample so no auth is set. It is important to set the authorization
### for API Gateway - Cognito or Lambda authorizer
########################################################################

resource "aws_api_gateway_method" "review" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.review.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_integration" "review" {
  http_method = aws_api_gateway_method.review.http_method
  resource_id = aws_api_gateway_resource.review.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  type        = "AWS_PROXY"
  uri         = var.lambda_invoke_arn
  integration_http_method = "POST"
}

resource "aws_lambda_permission" "apigw_lambda_function_chat_summary" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.review.http_method}${aws_api_gateway_resource.review.path}"
}





########################################################################
### API methods and integrations ends###########
########################################################################

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.api.body,
      aws_api_gateway_integration.review.id
      ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
# You can enable access logging using access_log_settings. 
# This allows delivery of custom logs CloudWatch.

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"
}
########################################################################
### API methods and rate control ###########
########################################################################

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"

  settings {
    # Set throttling values
    throttling_burst_limit = 1
    throttling_rate_limit  = 1

    metrics_enabled = true
  }
}

output "api_url" {
  description = "URL for product review approval"
  value       = "${aws_api_gateway_stage.stage.invoke_url}"
}
