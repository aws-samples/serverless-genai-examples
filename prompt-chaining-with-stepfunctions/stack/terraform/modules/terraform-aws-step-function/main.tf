# variables

variable "lambda_function_arn" {}
variable "event_bus_arn" {}
variable "event_bus_name" {}
variable resource_name {}
variable "api_url" {}

variable "claude2-modelId" {
   type = string
   default = "anthropic.claude-v2"
}
variable "claude3-modelId"{
   type = string
   default = "anthropic.claude-3-haiku-20240307-v1:0"
}
locals{
    source_dir = "../../src"
    name = "automatic-product-review-response-workflow"
}
data "aws_region" "current_region" {}

# AWS Step Functions IAM roles and Policies
resource "aws_iam_role" "aws_stf_role" {
  name = "stepfunctions-role-${var.resource_name}"

  assume_role_policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Action":"sts:AssumeRole",
         "Principal":{
            "Service":[
                "states.amazonaws.com"
            ]
         },
         "Effect":"Allow",
         "Sid":"StepFunctionAssumeRole"
      }
   ]
}
EOF
}

resource "aws_iam_role_policy" "step_function_policy" {
  
  role    = aws_iam_role.aws_stf_role.id
  policy  = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Action":[
            "lambda:InvokeFunction"
         ],
         "Effect":"Allow",
         "Resource":"${var.lambda_function_arn}"
      },
      {
         "Action":[
            "Bedrock:InvokeModel"
         ],
         "Effect":"Allow",
         "Resource":["arn:aws:bedrock:${data.aws_region.current_region.name}::foundation-model/${var.claude2-modelId}", 
                     "arn:aws:bedrock:${data.aws_region.current_region.name}::foundation-model/${var.claude3-modelId}"]
      },
      {
         "Action":[
            "comprehend:detectToxicContent"
         ],
         "Effect":"Allow",
         "Resource":"*"
      },
      {
         "Action":[
            "events:putEvents"
         ],
         "Effect":"Allow",
         "Resource":"${var.event_bus_arn}"
      }


  ]
}

EOF
}

# AWS Step function definition. Standard Step Functons is used as the workflow involves human in the loop
# Express workflows can not be used for wait for callback patterns.
# Standard workflows execution history is maintained in the console.
# Cloudwatch logging can be enabled using logging_configuration.
resource "aws_sfn_state_machine" "aws_step_function_workflow" {
  name = "stepfunctions-${var.resource_name}"
  role_arn = aws_iam_role.aws_stf_role.arn
  definition = templatefile("${local.source_dir}/workflow.asl.json", {
      region = data.aws_region.current_region.name
      claude2-model = var.claude2-modelId
      claude3-model = var.claude3-modelId
      human_approval_helper_lambda ="${var.lambda_function_arn}"
      eb_bus ="${var.event_bus_name}"
      api_url ="${var.api_url}"

      }
  )

}

# outputs
output "stf_role_arn" {
  value = aws_iam_role.aws_stf_role.arn
}
output "stf_name" {
  value = aws_sfn_state_machine.aws_step_function_workflow
}
output "stf_arn" {
  value = aws_sfn_state_machine.aws_step_function_workflow.arn
}