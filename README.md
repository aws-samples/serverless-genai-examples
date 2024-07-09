# GenAI examples using serverless

This repository contains examples of genAI applications using AWS serverless services.

## Contents

1. About this repo    
2. Examples
3. Learning Resources
4. License

## About this repo

This repo contains code examples of generative AI applications, workflows and patterns using serverless services such as AWS Step Functions, Lambda and EventBridge.

We welcome contributions to this repo - see [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## Examples
- [**Prompt chaining with human in the loop**](./prompt-chaining-with-stepfunctions/README.md)
This example demonstrate the use of prompt chaining to decompose bulk and inefficient prompt in to smaller prompts and using purpose built models. Example also shows how to include a human feedback loop when you need to improve the safety and accuracy of the application. 

- [**Tool use or Function calling example**](./tool-use-with-stepfunctions/README.md)
This example uses Anthropic's Claude Haiku model to show how [Tool use or Function calling](https://docs.anthropic.com/en/docs/build-with-claude/tool-use) can be achieved with Step Functions. [Amazon Bedrock supports tool use](https://docs.aws.amazon.com/bedrock/latest/userguide/tool-use.html) with Bedrock's `Converse` API, however, this mechanism can also be used with basic inference operations like Bedrock's `InvokeModel` or `InvokeWithResponseStreaming`. Tool use is a step above using Agents where the LLM figures out a tool to use but delegates the responsibility to the user to make use of it. This drastically reduces latency, token size, and deterministic characteristic of LLM responses.

- [**Book a private jet flight with Tool use**](./airline-reservation-tool-use/README.md)
This example uses Anthropic's Claude Sonnet 3 model to show how [Tool use or Function calling](https://docs.anthropic.com/en/docs/build-with-claude/tool-use) can be achieved with Step Functions for booking a reservation of a private jet with minimal information available.

## Learning resources
- [Serverless patterns](https://serverlessland.com/patterns)
- [Serverless workflows](https://serverlessland.com/workflows)

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
