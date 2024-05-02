# prompt_chaining_blog

This sample project supports the [blog]()
Refer the blog to understand the overall application architecture and technical concepts

## Getting started

### Prerequistes

[terraform](https://www.terraform.io/)
[aws_cli](https://aws.amazon.com/cli/)
[Python 3.11](https://www.python.org/downloads/release/python-3110/)

Make sure you have access to `anthropic.claude-v2` and `anthropic.claude-3-haiku-20240307-v1:0` in Amazon Bedrock. if not, follow the [process](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html) to get the access.

###

Add your email address in [variable.tf](stack/terraform/variables.tf) or enter the email when deploying the stack.

### Deploy

```bash
git clone <repo>
cd prompt-chaining-human-in-the-loop/stack/terraform
terraform init
terraform apply

```

Once deployed, confirm the subscription through the email received in the email address configured earlier.

### Run

- Login to AWS account and access the Step Functions console.
- Run the workflow named `stepfunctions-product-review-response-automation-stage` with the following input

```json
{
  "review_text": "The item broke in 2 days"
}
```

### cleanup

terraform destroy

## Contributing

Refer [contribution](./CONTRIBUTING.md)
