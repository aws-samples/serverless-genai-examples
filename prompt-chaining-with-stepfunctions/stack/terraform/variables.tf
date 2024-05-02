variable "event_bus_name" {
  description = "the name of the custom event bus"
  type    = string
  default = "product_review_event_router"
}
variable "email" {
  description = "Reviewer email"
  type    = string
}
variable "stage" {
  description = "stage of the deployment"
  type    = string
  default = "stage"
}
variable "project" {
  description = "name of the project"
  type    = string
  default = "product-review-response-automation"
}
