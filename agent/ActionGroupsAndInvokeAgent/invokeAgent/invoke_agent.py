import boto3
import json
import os
import uvicorn
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from typing import Optional
import uuid

def is_running_in_lambda():
	return "AWS_LAMBDA_FUNCTION_NAME" in os.environ

# Initialize FastAPI app
app = FastAPI()

# Initialize the Bedrock client
# Create a session using the specified profile
if is_running_in_lambda():
	session = boto3.Session(region_name='us-east-1')
else:
	session = boto3.Session(profile_name='mealPro', region_name='us-east-1')

# Create a client for the Bedrock runtime service using the session
bedrock_client = session.client("bedrock-agent-runtime", region_name="us-east-1")


# Define a request model using Pydantic
class InvokeAgentInput(BaseModel):
	agentAliasId: str = "TSTALIASID"
	agentId: str = "TKAFFO7AR2"
	inputText: str
	sessionId: Optional[str] = str(uuid.uuid4())

# POST endpoint for generating stories
@app.post("/api/invokeAgent")
def api_invokeAgent(invoke_agent_input: InvokeAgentInput):	# Check if the topic is provided
	if not invoke_agent_input.inputText:
		return {"error": "Input text is required"}

	# Call the Bedrock stream function and return the response as a stream
	return StreamingResponse(bedrock_stream(invoke_agent_input), media_type="text/html")


def extract_action_group_output(trace_data):
	"""Extracts and parses the JSON output from the action group trace."""
	if "actionGroupInvocationOutput" in trace_data:
		action_group_output = trace_data["actionGroupInvocationOutput"].get("text", "")
		try:
			return json.loads(action_group_output)
		except json.JSONDecodeError as e:
			print(f"Error decoding JSON: {e}")
			return None
	return None

def process_trace_event(trace_event):
	"""Processes trace events and returns relevant data for final JSON response."""
	orchestration_trace = trace_event.get('orchestrationTrace', {})
	if "observation" in orchestration_trace:
		observation = orchestration_trace["observation"]
		if "actionGroupInvocationOutput" in observation:
			return extract_action_group_output(observation)
	return None

# Function to stream responses from Bedrock
async def bedrock_stream(invoke_agent_input: InvokeAgentInput):

	# Initialize the variables from the input
	agentAliasId: str = invoke_agent_input.agentAliasId or "TSTALIASID"
	agentId = invoke_agent_input.agentId or "TKAFFO7AR2"
	inputText = invoke_agent_input.inputText
	sessionId = invoke_agent_input.sessionId
	print(f"Invoking Agent {agentId} and alias {agentAliasId} with input: {inputText} and session ID: {sessionId}")

	# Call the Bedrock client to invoke the agent
	try:
		response = bedrock_client.invoke_agent(
			agentId=agentId,
			agentAliasId=agentAliasId,
			sessionId=sessionId,
			inputText=inputText, 
			enableTrace=True, 
		)
	except Exception as e:
		output_msg = {
			"messageDetail": "Bedrock Error",
			"messageType": "trace",
			"text": f"Error invoking agent: {e}", 
			"display_msg": "Agent has errors! Please try again later."
		}
		yield json.dumps(output_msg) + "\n"
		return

	# extract the stream from the response
	stream = response.get('completion')
	accumulated_data = []

	if stream:
		# Iterate over each event in the stream
		for event in stream:
			# print("\nEvent")
			print(event)
			print("\n")
			# Check if the event has a 'trace' key
			if "chunk" in event:
				chunk = event.get('chunk')
				raw_data = chunk.get("bytes").decode("utf-8")
				# print("\nChunk's raw data")
				# print(f"Raw data: {raw_data}")  # Debug print to inspect the raw data
				try: 

					# Decode the bytes and parse the JSON content
					message = json.loads(raw_data)
					print(f"Decoded JSON message: {message}")  
					final_response = {
							"messageType": "chunk",
							"recipes": message["recipes"],
							"text": message["explanation"]
						}
					yield json.dumps(final_response)

				# Debug print to see the JSON structure
				except json.JSONDecodeError as e:

					if accumulated_data:
						final_response = {
							"messageType": "chunk",
							"recipes": accumulated_data,
							"text": raw_data
						}
						yield json.dumps(final_response)
					else: 
						print("Data is not JSON; treating as plain text.")
						yield json.dumps({
							"messageType": "chunk", 
							"text": raw_data
							})

			elif 'trace' in event:
				trace = event['trace']['trace']
				# processed_data = process_trace_event(trace)
				# if processed_data:
				# 	accumulated_data.extend(processed_data)
				orchestration_trace = trace.get('orchestrationTrace')
				postProcessingTrace = trace.get('postProcessingTrace')
				if postProcessingTrace:
					if "modelInvocationInput" in postProcessingTrace:
						# message_detail = postProcessingTrace["modelInvocationInput"]["type"]
						output_msg = {
							"messageDetail": "modelInvocationInput",
							"messageType": "trace",
							"text": "Post Processing Trace",
							"display_msg": "Formatting the final response!"
						}
						yield json.dumps(output_msg) + "\n"
				# print("\nTrace event found !")
				# print(orchestration_trace.keys())
				elif "modelInvocationInput" in orchestration_trace:
					print("Model invocation input")
					message_detail = orchestration_trace["modelInvocationInput"]["type"]
					output_msg = {
						"messageDetail": "modelInvocationInput",
						"messageType": "trace", 
						"text": message_detail, 
						"display_msg": "Hang Tight, we are working on it!"
					}
					yield json.dumps(output_msg) + "\n"
					# yield f"Model invocation Input trace event found of type {orchestration_trace['modelInvocationInput']['type']}\n"

				elif "modelInvocationOutput" in orchestration_trace:
					print("Model invocation output")
					message_detail = orchestration_trace["modelInvocationOutput"]["rawResponse"]["content"]
					output_msg = {
						"messageDetail": "modelInvocationOutput",
						"messageType": "trace",
						"text": message_detail, 
						"display_msg": "Agent is thinking!"
					}
					yield json.dumps(output_msg) + "\n"
					# yield f"Model invocation Ouput trace event found with response of  {orchestration_trace["modelInvocationOutput"]["rawResponse"]["content"]}\n"

				elif "rationale" in orchestration_trace:
					print("Rationale")
					message_detail = orchestration_trace["rationale"]["text"]
					output_msg = {
						"messageDetail": "rationale",
						"messageType": "trace",
						"text": message_detail,
						"display_msg": "Agent is thinking!"
					}
					yield json.dumps(output_msg) + "\n"
					# yield f"Rationale trace event found with response of  {orchestration_trace["rationale"]["text"]}\n"

				# elif "invocationInput" in orchestration_trace:
				#     print("Invocation input")
				elif "invocationInput" in orchestration_trace:
					print("Invocation input")
					if "actionGroupInvocationInput" in orchestration_trace["invocationInput"]:
						message_detail = orchestration_trace['invocationInput']['actionGroupInvocationInput']
						output_msg = {
							"messageDetail": "actionGroupInvocationInput",
							"messageType": "trace",
							"text": message_detail,
							"display_msg": "Agent is calling on its resources!"
						}
						yield json.dumps(output_msg) + "\n"
						# yield f"Invocation input trace event found with response of {orchestration_trace['invocationInput']['actionGroupInvocationInput']}\n"
					elif "invocationType" in orchestration_trace["invocationInput"]:
						message_detail = orchestration_trace['invocationInput']['invocationType']
						output_msg = {
							"messageDetail": "invocationType",
							"messageType": "trace",
							"text": message_detail,
							"display_msg": "Agent is calling on its resources!"
						}
						yield json.dumps(output_msg) + "\n"
						# yield f"Invocation input trace event found with response of {orchestration_trace['invocationInput']['invocationType']}\n"

				elif "observation" in orchestration_trace:
					print("Observation")
					message_detail = orchestration_trace["observation"]["type"]
					output_msg = {
						"messageDetail": "observation",
						"messageType": "trace",
						"text": message_detail,
						"display_msg": "Almost there!"
					}
					yield json.dumps(output_msg) + "\n"
					# yield f"Observation trace event found of type {orchestration_trace["observation"]["type"]} \n"

			elif 'accessDeniedException' in event:
				yield f"Access Denied: {event['accessDeniedException']['message']}\n"

			elif 'badGatewayException' in event:
				yield f"Bad Gateway: {event['badGatewayException']['message']}\n"

			elif 'conflictException' in event:
				yield f"Conflict: {event['conflictException']['message']}\n"

			elif 'internalServerException' in event:
				yield f"Internal Server Error: {event['internalServerException']['message']}\n"

			elif 'validationException' in event:
				yield f"Validation Error: {event['validationException']['message']}\n"

			elif 'throttlingException' in event:
				yield f"Throttling: {event['throttlingException']['message']}\n"

			elif 'serviceQuotaExceededException' in event:
				yield f"Service Quota Exceeded: {event['serviceQuotaExceededException']['message']}\n"

			else:
				yield "No chunk data available.\n"

# Run the app using Uvicorn when executed directly
if __name__ == "__main__":
	uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", "8080")))