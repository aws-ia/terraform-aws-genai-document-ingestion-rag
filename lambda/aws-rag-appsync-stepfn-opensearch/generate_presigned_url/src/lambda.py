#
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance
# with the License. A copy of the License is located at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# or in the 'license' file accompanying this file. This file is distributed on an 'AS IS' BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions
# and limitations under the License.
#
import os
import boto3

from aws_lambda_powertools import Logger, Tracer, Metrics
from aws_lambda_powertools.metrics import MetricUnit

logger = Logger(service="GENERATE_PRESIGNED_URL")
tracer = Tracer(service="GENERATE_PRESIGNED_URL")
metrics = Metrics(namespace="PresignedURLService", service="GENERATE_PRESIGNED_URL")

s3_client = boto3.client('s3')
INPUT_ASSETS_BUCKET_NAME = os.environ['INPUT_ASSETS_BUCKET_NAME']

def generate_presigned_url(bucket_name: str, object_name: str, expiration: int, operation:str, content_type: str) -> None:
    try:
        return s3_client.generate_presigned_url(
            ClientMethod=operation,
            Params={'Bucket': bucket_name, 'Key': object_name, 'ContentType': content_type},
            ExpiresIn=expiration)
    except Exception as e:
        logger.error(f"Error generating presigned url: {str(e)}")
        return None

def isvalid_file_format(file_name: str) -> bool:
    file_format = ['.pdf','.txt','.jpg','.jpeg','.png','.svg']
    if file_name.endswith(tuple(file_format)):
        print(f'valid file format :: {file_format}')
        return True
    else:
        print(f'Invalid file format :: {file_format}')
        return False

def is_valid_operation(operation):
    allowed_operations = ['put_object', 'get_object']
    return operation in allowed_operations

@logger.inject_lambda_context(log_event=True)
@tracer.capture_lambda_handler
@metrics.log_metrics(capture_cold_start_metric=True)
def lambda_handler(event, context):
    arguments = event.get('arguments', {})
    file_name = arguments.get('fileName', '')
    operation = arguments.get('operation', 'put_object')
    content_type = arguments.get('content_type', 'application/pdf')
    expiration = arguments.get('expiration', 3600)

    if not file_name:
        metrics.add_metric(name="InvalidRequest", unit=MetricUnit.Count, value=1)
        return {
            'success': False,
            'message': 'FileName is required',
            'fileName': None,
            'url': None,
        }
    if not is_valid_operation(operation):
        return {
            'success': False,
            'message': 'Invalid operation',
            'fileName': None,
            'url': None,
        }

    if not isvalid_file_format(file_name):
        return {
            'success': False,
            'message': 'Invalid file format',
            'fileName': file_name,
            'url': None,
        }

    try:
        presigned_url = generate_presigned_url(INPUT_ASSETS_BUCKET_NAME, file_name, expiration, operation, content_type)
        metrics.add_metric(name="PresignedURLGenerated", unit=MetricUnit.Count, value=1)

    except Exception as e:
        logger.error(f"Error generating presigned url: {str(e)}")
        metrics.add_metric(name="PresignedURLGenerationError", unit=MetricUnit.Count, value=1)
        return {
            'success': False,
            'message': 'Error generating presigned URL',
            'fileName': file_name,
            'url': None,
        }

    return {
        'success': True,
        'message': 'Presigned URL generated successfully',
        'fileName': file_name,
        'url': presigned_url,
    }
