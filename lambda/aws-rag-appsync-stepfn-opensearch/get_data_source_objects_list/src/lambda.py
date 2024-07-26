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
from aws_lambda_powertools import Logger, Tracer, Metrics
from aws_lambda_powertools.metrics import MetricUnit
import boto3
import os
import json

logger = Logger(service="GET_DATA_SOURCE_OBJECTS_LIST")
tracer = Tracer(service="GET_DATA_SOURCE_OBJECTS_LIST")
metrics = Metrics(namespace="DataSource", service="GET_DATA_SOURCE_OBJECTS_LIST")

s3 = boto3.client('s3')
INPUT_ASSETS_BUCKET_NAME = os.environ['INPUT_ASSETS_BUCKET_NAME']

@logger.inject_lambda_context(log_event=True)
@tracer.capture_lambda_handler
@metrics.log_metrics(capture_cold_start_metric=True)

def process_files_list_result(files_list, context):
    if not files_list:
        logger.error("Received empty or invalid file list.")
        return []

    processed_files = []
    for file in files_list:
        if 'Key' not in file or 'LastModified' not in file or 'Size' not in file:
            logger.error(f"Invalid file data: {file}")
            continue

        processed_file = {
            "Name": file['Key'],
            "LastModified": file['LastModified'].strftime('%Y-%m-%d %H:%M:%S'),
            "Size": file['Size'],
        }
        processed_files.append(processed_file)
    return processed_files

def lambda_handler(event, context):
    try:
        logger.info("Received event: " + json.dumps(event, indent=2))
        response = s3.list_objects_v2(Bucket=INPUT_ASSETS_BUCKET_NAME)
        objects = response.get('Contents', [])
        logger.info(f"Got objects list: {objects}")
        processed_files = process_files_list_result(objects, context)
        return {
            'success': True,
            'message': 'Successfully getting objects list',
            'objects': processed_files,
            'count': len(objects),
        }
    except Exception as e:
        metrics.add_metric(name="DataSourceErrors", unit=MetricUnit.Count, value=1)
        logger.error(str(e))
        return {
            'success': False,
            'message': 'Error getting objects list',
            'objects': None,
            'count': None,
        }
