# terraform and AWS configurations
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.29"
    }
  }
}

# Modules

module "util_services" {
  source  = "./modules/terraform-util-services"
  event_bus_name = var.event_bus_name
  email = var.email
}

module "aws_lambda_function" {
  source          = "./modules/terraform-aws-lambda"
  resource_name = "${var.project}-${var.stage}" 
  sns_topic_arn = module.util_services.sns_topic_arn
  dynamodb_arn = module.util_services.dynamodb_arn
  dynamodb_name = module.util_services.dynamodb_name

}

module "api_gateway" {
  source  = "./modules/terraform-api-gateway"
  resource_name = "${var.project}-${var.stage}" 
  lambda_invoke_arn = module.aws_lambda_function.lambda_invoke_arn
  lambda_function_name = module.aws_lambda_function.lambda_function_name

}

module "aws_sfn_state_machine" {
  source              = "./modules/terraform-aws-step-function"
  lambda_function_arn = module.aws_lambda_function.lambda_function_arn
  resource_name = "${var.project}-${var.stage}" 
  event_bus_name = var.event_bus_name
  event_bus_arn = module.util_services.event_bus_arn
  api_url = module.api_gateway.api_url

}


# Outputs
output "aws_lambda_function_arn" {
  value = module.aws_lambda_function.lambda_function_arn
  
}
output "api_gateway_url" {
  value = module.api_gateway.api_url
}

output "aws_step_function_arn" {
  value = module.aws_sfn_state_machine.stf_role_arn
}
