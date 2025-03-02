import { defineBackend } from '@aws-amplify/backend';
import { auth } from './auth/resource';
import { data } from './data/resource';
import { fetchRecipes } from './functions/fetchRecipes/resource';
import * as iam from 'aws-cdk-lib/aws-iam';
import {CfnApp} from "aws-cdk-lib/aws-pinpoint"
import { Stack } from 'aws-cdk-lib/core';

/**
 * @see https://docs.amplify.aws/react/build-a-backend/ to add storage, functions, and more
 */
const backend = defineBackend({
  auth,
  data,
  fetchRecipes,
});

const invokePolicy = new iam.PolicyStatement({
  sid: "AllowAuthUsersToInvokeAgentLambda", 
  actions: ['lambda:InvokeFunctionUrl', 'lambda:InvokeFunction'],
  resources: ["arn:aws:lambda:us-east-1:294090989896:function:agent-InvokeAgentFunctionV2-8IK28QD6LjQg"]
})

backend.auth.resources.authenticatedUserIamRole.addToPrincipalPolicy(invokePolicy);


const opensearchPolicy = new iam.PolicyStatement({
  sid: "AllowAuthUsersToAccessOpenSearch",
  actions: [
    "aoss:APIAccessAll",
    "aoss:DashboardsAccessAll", 
    "aoss:*", 
    "aoss:DescribeCollection",
    "aoss:DescribeIndex",
    "aoss:ReadDocument",
    "aoss:ListCollections"
  ],
  resources: [
    "arn:aws:aoss:us-east-1:294090989896:collection/*",
    "arn:aws:aoss:us-east-1:294090989896:dashboards/default", 
    "arn:aws:aoss:us-east-1:294090989896:index/bedrock-sample-rag-02270857-c/*",
  ]
});

backend.auth.resources.authenticatedUserIamRole.addToPrincipalPolicy(opensearchPolicy);

const analyticsStack = backend.createStack("analytics-stack")

// create a Pinpoint app
const pinpoint = new CfnApp(analyticsStack, "Pinpoint", {
  name: "mealProPinpointApp"
});

const pinpointPolicy = new iam.Policy(analyticsStack, "PinpointPolicy", {
  policyName: "PinpointPolicy", 
  statements: [
    new iam.PolicyStatement({
      actions: ["mobiletargeting:UpdateEndpoint", "mobiletargeting:PutEvents"], 
      resources: [pinpoint.attrArn + "/*"]
    })
  ]
});

backend.auth.resources.authenticatedUserIamRole.attachInlinePolicy(pinpointPolicy);
backend.auth.resources.unauthenticatedUserIamRole.attachInlinePolicy(pinpointPolicy);

backend.addOutput({
  analytics: {
    amazon_pinpoint: {
      app_id: pinpoint.ref, 
      aws_region: Stack.of(pinpoint).region
    }
  }
});