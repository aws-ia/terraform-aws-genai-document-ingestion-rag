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
import requests
import json
import boto3
from requests_aws4auth import AWS4Auth

from aws_lambda_powertools import Logger, Tracer

logger = Logger(service="INGESTION_INPUT_VALIDATION")
tracer = Tracer(service="INGESTION_INPUT_VALIDATION")

aws_region = boto3.Session().region_name
credentials = boto3.Session().get_credentials()
service = 'appsync'
aws_auth = AWS4Auth(
    credentials.access_key,
    credentials.secret_key,
    aws_region,
    service,
    session_token=credentials.token,
)

@tracer.capture_method
def get_credentials(secret_id: str, region_name: str) -> str:

    client = boto3.client('secretsmanager', region_name=region_name)
    response = client.get_secret_value(SecretId=secret_id)
    secrets_value = response['SecretString']

    return secrets_value

@tracer.capture_method
def updateIngestionJobStatus(variables):

    print(f"send  status variables :: {variables}")

    query = """
        mutation updateIngestionJobStatus {
            updateIngestionJobStatus(files: $files, ingestionjobid: \"$jobid\") {
                files {
                    name
                    status
                }
                ingestionjobid
            }
        }
    """

    query = query.replace("$jobid", str(variables['jobid']))
    query = query.replace("$files", str(variables['files']).replace("\'", "\""))
    query = query.replace("\"name\"", "name")
    query = query.replace("\"status\"", "status")

    request = {'query':query}

    logger.info({"request": request})

    GRAPHQL_URL = os.environ['GRAPHQL_URL']
    HEADERS={
        "Content-Type": "application/json",
    }
    try:
        responseJobstatus = requests.post(
            json=request,
            url=GRAPHQL_URL,
            headers=HEADERS,
            auth=aws_auth,
            timeout=10
        )
        responseJobstatus.raise_for_status()  # Raises an HTTPError for bad responses
        logger.info({'res :: ': responseJobstatus.json()})
    except Exception as e:
        logger.error(f"An error occurred: {e}")

    # responseJobstatus = requests.post(
    #     json=request,
    #     url=GRAPHQL_URL,
    #     headers=HEADERS,
    #     auth=aws_auth,
    #     timeout=10
    # )
    # responseJobstatus.raise_for_status()
    # logger.info({'res :: ': responseJobstatus})