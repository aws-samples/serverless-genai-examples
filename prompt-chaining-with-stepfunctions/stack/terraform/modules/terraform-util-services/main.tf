
# variables

variable "event_bus_name" {}
variable "email" {}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}


########################################################################
###    SNS TOPIC AND EMAIL SUBSCRIPTION                      ###########
########################################################################
# You can enable SNS encryption using kms_master_key_id
resource "aws_sns_topic" "product_review_approvals" {
  name = "product_review_approvals_topic"
  kms_master_key_id = "alias/aws/sns"

}

resource "aws_sns_topic_subscription" "product_reviewer_email" {
  topic_arn = aws_sns_topic.product_review_approvals.arn
  protocol  = "email"
  endpoint  = var.email
}

########################################################################
###    EB BUS AND DEFAULT TARGET AS LOG                      ###########
########################################################################

resource "aws_cloudwatch_event_bus" "product_review_eventrouter" {
  name = var.event_bus_name
}

resource "aws_cloudwatch_event_rule" "catch_all" {
    name           = "catch_all"
    description    = "default catch all"
    event_bus_name = aws_cloudwatch_event_bus.product_review_eventrouter.name
    event_pattern  = jsonencode(
        {
            account = [
                "${local.account_id}",
            ]
        }
    )
}

resource "aws_cloudwatch_log_group" "log" {
  name = "/aws/events/${aws_cloudwatch_event_bus.product_review_eventrouter.name}/${var.event_bus_name}-catch_all"

  retention_in_days = 7
}

resource "aws_cloudwatch_event_target" "cw_log" {
  rule      = aws_cloudwatch_event_rule.catch_all.name
  arn       = aws_cloudwatch_log_group.log.arn
  event_bus_name = aws_cloudwatch_event_bus.product_review_eventrouter.name
  depends_on = [aws_cloudwatch_log_group.log]
}

resource "aws_dynamodb_table" "tasktoken-dynamodb-table" {
  name           = "human_approval_data"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "runid"
  range_key      = "stage"

  attribute {
    name = "runid"
    type = "S"
  }

  attribute {
    name = "stage"
    type = "S"
  }

  # ttl {
  #   attribute_name = "TimeToExist"
  #   enabled        = false
  # }

}
########################################################################
###    OUTPUTS              ###########
########################################################################
output "event_bus_arn" {
  value =  aws_cloudwatch_event_bus.product_review_eventrouter.arn
}

output "sns_topic_arn" {
  value =  aws_sns_topic.product_review_approvals.arn
}

output "dynamodb_arn" {
  value =  aws_dynamodb_table.tasktoken-dynamodb-table.arn
}

output "dynamodb_name" {
  value =  aws_dynamodb_table.tasktoken-dynamodb-table.id
}
# output "bucket_arn" {
#   value =  aws_s3_bucket.doc-bucket.arn
# }
# output "bucket_name" {
#   value =  aws_s3_bucket.doc-bucket.id
# }
