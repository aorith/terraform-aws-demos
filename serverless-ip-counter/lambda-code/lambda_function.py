import os

import boto3
from botocore.exceptions import ClientError


def update_counter(address: str):
    ddb = boto3.resource("dynamodb")
    table = ddb.Table(os.environ["DDB_TABLE_NAME"])

    try:
        response = table.update_item(
            Key={"address": address},
            UpdateExpression="SET #v = if_not_exists(#v, :start) + :inc",
            ExpressionAttributeNames={"#v": "value"},
            ExpressionAttributeValues={":inc": 1, ":start": 0},
            ReturnValues="UPDATED_NEW",
        )
        return response["Attributes"]["value"]
    except ClientError as e:
        print(f"Error updating value: {e}")
        return None


def lambda_handler(event, context):
    request_context = event["requestContext"]
    source_ip = request_context["http"]["sourceIp"]

    count = update_counter(source_ip)
    if count is None:
        return {"statusCode": 500, "body": "Error updating counter"}

    body = {"address": source_ip, "count": count}
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": body,
    }
