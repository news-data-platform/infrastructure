import os
import boto3
import io
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")

def handler(event, context):
    logger.info("Lambda triggered")

    bucket = os.getenv("S3_BUCKET_NAME")
    if not bucket:
        logger.error("Environment variable S3_BUCKET_NAME is missing")
        return

    buffer = io.BytesIO()
    buffer.write(b"test file")
    buffer.seek(0)

    s3.upload_fileobj(buffer, bucket, "test.csv")

    logger.info("Uploaded test.csv to S3")
