import boto3
import logging
import os

def lambda_handler(event, context):
    glue_client = boto3.client('glue')
    crawlers = [os.environ["EC2_CRAWLER"], os.environ["AUTO_CRAWLER"],os.environ["EBS_CRAWLER"],os.environ["LAMBDA_CRAWLER"] ]

    for crawler in crawlers:
        try:
            glue_client.start_crawler(Name=crawler)
        except Exception as e:
            # Send some context about this error to Lambda Logs
            logging.warning("%s" % e)