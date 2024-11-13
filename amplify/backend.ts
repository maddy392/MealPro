import { defineBackend } from '@aws-amplify/backend';
import { auth } from './auth/resource';
import { data } from './data/resource';
import { fetchRecipes } from './functions/fetchRecipes/resource';
import * as iam from 'aws-cdk-lib/aws-iam';

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