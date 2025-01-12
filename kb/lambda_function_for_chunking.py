import json
import os
from abc import abstractmethod, ABC
from typing import List
import boto3
import logging
import csv
from io import StringIO

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

# Abstract Base Class for Chunkers
class Chunker(ABC):
    @abstractmethod
    def chunk(self, text: str) -> List[str]:
        raise NotImplementedError()

# Simple Chunker Implementation
class SimpleChunker(Chunker):
    def chunk(self, text: str) -> List[str]:
        words = text.split()
        return [' '.join(words[i:i+100]) for i in range(0, len(words), 100)]

# Lambda Handler
def lambda_handler(event, context):

    logger.debug(f"Input: {json.dumps(event)}")
    s3 = boto3.client('s3')

    # Extract relevant input parameters
    input_files = event.get('inputFiles')
    input_bucket = event.get('bucketName')

    if not all([input_files, input_bucket]):
        raise ValueError("Missing required input parameters")

    output_files = []
    chunker = SimpleChunker()

    for input_file in input_files:
        content_batches = input_file.get('contentBatches', [])
        file_metadata = input_file.get('fileMetadata', {})
        original_file_location = input_file.get('originalFileLocation', {})

        processed_batches = []

        for batch in content_batches:
            input_key = batch.get('key')

            if not input_key:
                raise ValueError("Missing key in content batch")

            # Read file from S3
            file_content = read_s3_file(s3, input_bucket, input_key)
            logger.debug(f"File content: {json.dumps(file_content)}")

            # Process content (chunking title and ingredients)
            chunked_content = process_recipe_content(file_content, chunker)
            logger.debug(f"Chunked content: {json.dumps(chunked_content)}")

            output_key = f"Output/{input_key}"

            # Write processed content back to S3
            write_to_s3(s3, input_bucket, output_key, chunked_content)

            # Add processed batch information
            processed_batches.append({
                'key': output_key
            })

        # Prepare output file information
        output_file = {
            'originalFileLocation': original_file_location,
            'fileMetadata': file_metadata,
            'contentBatches': processed_batches
        }
        output_files.append(output_file)

    result = {'outputFiles': output_files}
    return result

# Utility to Read File from S3
def read_s3_file(s3_client, bucket, key):
    response = s3_client.get_object(Bucket=bucket, Key=key)
    return json.loads(response['Body'].read().decode('utf-8'))

# Utility to Write File to S3
def write_to_s3(s3_client, bucket, key, content):
    s3_client.put_object(Bucket=bucket, Key=key, Body=json.dumps(content))


def process_recipe_content(file_content: dict, chunker: Chunker) -> dict:
    chunked_content = {
        'fileContents': []
    }

    for content in file_content.get('fileContents', []):
        content_body = content.get('contentBody', '')
        content_metadata = content.get('contentMetadata', {})
        original_content_type = content.get('contentType', 'UNKNOWN')  # Default to 'UNKNOWN' if not provided

        # Parse CSV data
        csv_reader = csv.DictReader(StringIO(content_body))
        for row in csv_reader:
            title = row.get('title', '')
            ingredients = row.get('ingredients', '')

            # Create the title chunk
            chunked_content['fileContents'].append({
                'contentType': original_content_type,
                'contentMetadata': {**content_metadata, 'chunk_type': 'title'},
                'contentBody': title
            })

            # Create the ingredients chunk (ingredients are already a single string in CSV)
            chunked_content['fileContents'].append({
                'contentType': original_content_type,
                'contentMetadata': {**content_metadata, 'chunk_type': 'ingredients'},
                'contentBody': ingredients
            })

    return chunked_content