import fastapi
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
import boto3
from botocore.client import Config
import logging
# import uvicorn

logger = logging.getLogger('uvicorn.error')

app = fastapi.FastAPI()

@app.get("/foobar")
async def foobar():
    return {"message": "hello world"}

@app.get("/s3")
async def s3():
    logger.warning("zero")
    s3 = boto3.resource(
        's3', 
        # Node 01 100.124.182.45
        # Node 02 100.124.182.46
        endpoint_url="https://100.124.182.45", 
        verify=False,
        region_name=None,
        config=Config(connect_timeout=5, read_timeout=5, retries={'max_attempts': 0},s3={'addressing_style': 'path'})
        )
    logger.warning("one")
    loki_bucket = s3.Bucket('grafana-loki')
    logger.warning("two")
    for my_bucket_object in loki_bucket.objects.all():
        logger.warning(my_bucket_object.key)
    return {"message": "s3 buckets"}

FastAPIInstrumentor.instrument_app(app)