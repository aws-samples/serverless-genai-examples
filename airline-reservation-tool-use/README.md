# Tool use to book a private jet

This project uses Tool use or function calling to book a reservation for a private jet.
The owner or the owner's PA would simply ask or chat and say:

*Mr. John Doe will be traveling to Orlando, FL in 5 hours with his family. I will need to book a reservation for them.*

and the system should be able to book a reservation or at least create a JSON payload to book the reservation. 

With tool use, LLMs can integrate with existing business logic and create some kind of magic. Today, this is still in its nascent phase because LLMs are indeterministic in nature. Therefore, results may vary between each runs.

## Deploy the sample application

To deploy this application, you need the following tools. You will also need access to Claude 3 Sonnet model in Bedrock. 
You can follow [this model access user guide](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html) to gain access.

* SAM CLI - [Install the SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
* Node.js - [Install Node.js 20](https://nodejs.org/en/), including the NPM package management tool.

To build and deploy your application for the first time, run the following in your shell:

```bash
sam build && sam deploy --guided
```

Provide these information when asked:

```bash
Setting default arguments for 'sam deploy'
=========================================
Stack Name [airline-reservation-tool-use]: 
AWS Region [us-east-1]: 
#Shows you resources changes to be deployed and require a 'Y' to initiate deploy
Confirm changes before deploy [y/N]: 
#SAM needs permission to be able to create roles to connect to the resources in your template
Allow SAM CLI IAM role creation [Y/n]: 
#Preserves the state of previously provisioned resources when an operation fails
Disable rollback [y/N]: 
Save arguments to configuration file [Y/n]: 
SAM configuration file [samconfig.toml]: 
SAM configuration environment [default]: 
```

You can find your State Machine ARN in the output values displayed after deployment.

## Testing this app from Step Functions console
You can try various other prompts from [`sample_prompts.txt`](./sample_prompts.txt).
Execute the Step Functions by providing this input payload.

```json
{
  "content": "Mr. John Doe (OwnerId: 9612f6c4-b7ff-4d82-b113-7b605e188ed9) will be traveling by himself to re:Invent 2024 on Nov 30. I will need to book a reservation for him."
}
```

Check state machine response in the last success step.

Most notable, you should see below items:

 - The payload that is available for `BookReservation` Lambda function:
 ```json
{
  "ownerId": "9612f6c4-b7ff-4d82-b113-7b605e188ed9",
  "firstname": "John",
  "lastname": "Doe",
  "date": "2024-11-30T00:00:00Z",
  "from": "KJFK",
  "to": "KLAS",
  "passengers": []
}
 ```
 - Claude Sonnet model figured out that the nearest airport for re:Invent
 - With the help of other tools, it figured out the departure date, the home airport (JFK) of the owner.'

The end response from LLM would look something like:

```
The reservation has been booked for Mr. John Doe to fly alone from New York (KJFK) to Las Vegas (KLAS) on November 30, 2024 to attend the re:Invent 2024 conference.\n\nPlease let me know if you need any other assistance.
```

Try playing with other prompts that hints on adding family members to the trip. For example:

*Mr. John Doe (OwnerId: 9612f6c4-b7ff-4d82-b113-7b605e188ed9) will be traveling to Disney World in 5 hours with his family. I will need to book a reservation for them.*

The series of conversation between the user and the assistant would look like:

1. Based on input prompt, the LLM decides to use the `get_owner_info` tool to better serve the request. `get_owner_info` is your internal business logic:
```json
"content": [
  {
    "type": "text",
    "text": "Okay, let me break this down and get the details needed to book the reservation:\n\nownerId: 9612f6c4-b7ff-4d82-b113-7b605e188ed9\nfirstname: John  \nlastname: Doe"
  },
  {
    "type": "tool_use",
    "id": "toolu_bdrk_01HUzkSodua1PN7dqy8MR5DZ",
    "name": "get_owner_info",
    "input": {
      "ownerId": "9612f6c4-b7ff-4d82-b113-7b605e188ed9"
    }
  }
],
```

2. Once you feedback the user info to the LLM as additional context, next the LLM will dive deeper to get all passengers that needs to be added in reservation. Notice how the LLM figured out that MCO (Orlando Airport) is the nearest major airport to Disney World:
```json
"content": [
  {
    "type": "text",
    "text": "So the departure airport (from) will be JFK.\n\nFor the arrival airport (to), Disney World is located near Orlando, FL. The major airport code for Orlando is MCO.\n\nThe travel date and time is 5 hours from the current time, which is:\nTuesday, July 9th 2024, 1:05:35 AM UTC"
  },
  {
    "type": "tool_use",
    "id": "toolu_bdrk_01UBvTSEjBSGUYdyZwpEVuqZ",
    "name": "get_passengers",
    "input": {
      "ownerId": "9612f6c4-b7ff-4d82-b113-7b605e188ed9"
    }
  }
],
```

3. Now that it has figured out the passengers, date of travel, and airports, the LLM will direct to use the `book_reservation` tool:
```json
"content": [
{
  "type": "text",
  "text": "Based on the passenger info, the owner John Doe is traveling with his wife Jill Doe and two daughters Jane and Jenny Doe.\n\nLet me invoke the book_reservation tool now:"
},
{
  "type": "tool_use",
  "id": "toolu_bdrk_01CJ1VKM98ZPd6mJoqXmJJHe",
  "name": "book_reservation",
  "input": {
    "ownerId": "9612f6c4-b7ff-4d82-b113-7b605e188ed9",
    "firstname": "John",
    "lastname": "Doe",
    "date": "2024-07-09T01:05:35Z",
    "from": "KJFK",
    "to": "KMCO",
    "passengers": [
      {
        "firstname": "Jill",
        "lastname": "Doe"
      },
      {
        "firstname": "Jane",
        "lastname": "Doe"
      },
      {
        "firstname": "Jenny",
        "lastname": "Doe"
      }
    ]
  }
}
],
```

4. Finally, there is no more tool to use, therefore, the LLM responds with a generic message about what was done:

```json
{
  "output": {
    "Body": {
      "id": "msg_bdrk_01SmjogkHYHoDxGrCkrujhWQ",
      "type": "message",
      "role": "assistant",
      "model": "claude-3-sonnet-20240229",
      "content": [
        {
          "type": "text",
          "text": "The reservation has been booked for John Doe and his family (Jill, Jane, Jenny Doe) to fly from JFK airport in New York to Orlando International Airport (MCO) which is the closest major airport to Disney World. The flight departure time is set for 5 hours from the current time of July 9th 2024 8:05pm UTC, which is 1:05am UTC on July 10th.\n\nPlease confirm if this booking looks correct or if any changes need to be made."
        }
      ],
      "stop_reason": "end_turn",
      "stop_sequence": null,
      "usage": {
        "input_tokens": 1294,
        "output_tokens": 116
      }
    },
    "ContentType": "application/json"
  },
  "outputDetails": {
    "truncated": false
  },
  "resource": "invokeModel",
  "resourceType": "bedrock"
}
```

## Cleanup

To delete the sample application that you created, use the AWS CLI. Assuming you used your project name for the stack name, you can run the following:

```bash
sam delete --stack-name airline-reservation-tool-use
```

## Resources

See the [AWS SAM developer guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html) for an introduction to SAM specification, the SAM CLI, and serverless application concepts.

Next, you can use AWS Serverless Application Repository to deploy ready to use Apps that go beyond hello world samples and learn how authors developed their applications: [AWS Serverless Application Repository main page](https://aws.amazon.com/serverless/serverlessrepo/)
