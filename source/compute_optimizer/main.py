import boto3
import json
from datetime import date, timedelta
import json
import os
import logging
from botocore.client import Config

def get_ec2_instance_recommendations(accountid, region):
    client = boto3.client('compute-optimizer', region_name=region)
    try:
        response = client.get_ec2_instance_recommendations(

            accountIds=[
                accountid,
            ]
        )
        
        data  = response['instanceRecommendations']
        
        return data
    except Exception as e:
                pass
                logging.warning(f"{e} - {accountid}")


def get_auto_scaling_group_recommendations(accountid, region):
    client = boto3.client('compute-optimizer', region_name=region)
    try:
        response = client.get_auto_scaling_group_recommendations(

            accountIds=[
                accountid,
            ]
        )
        data  = response['autoScalingGroupRecommendations']
        
        return data
    except Exception as e:
                pass
                logging.warning(f"{e} - {accountid}")

def get_lambda_function_recommendations(accountid, region):
    client = boto3.client('compute-optimizer', region_name=region)
    try:
        response = client.get_lambda_function_recommendations(

            accountIds=[
                accountid,
            ]
        )
        data  = response['lambdaFunctionRecommendations']
        
        return data
    except Exception as e:
                pass
                logging.warning(f"{e} - {accountid}")


def get_ebs_volume_recommendations(accountid, region):
    client = boto3.client('compute-optimizer', region_name=region)
    try:
        response = client.get_ebs_volume_recommendations(

            accountIds=[
                accountid,
            ]
        )
        data  = response['volumeRecommendations']
        
        return data
    except Exception as e:
                pass
                logging.warning(f"{e} - {accountid}")


def write_file(file_name, data):
    with open('/tmp/%s.json' %file_name, 'w') as outfile:
     
        for item in data:
            if item is None or len(item) == 0:
                pass
            try:
                for instanceArn in item:
                    del instanceArn['lastRefreshTimestamp']
                    json.dump(instanceArn, outfile)
                    outfile.write('\n')
            except Exception as e:
                pass
                logging.warning("%s" % e)


def s3_upload(recommendations, Region, account_id):
    today = date.today()
    year = today.year
    month = today.month
    try:
        S3BucketName = os.environ["BUCKET_NAME"]
        s3 = boto3.client('s3', Region,
                            config=Config(s3={'addressing_style': 'path'}))
        s3.upload_file(f'/tmp/{recommendations}_recommendations.json', S3BucketName, f"Compute_Optimizer/Compute_Optimizer_{recommendations}/year={year}/month={month}/{recommendations}_recommendations_{account_id}.json")
        print(f"{recommendations} data in s3 {S3BucketName}")
    except Exception as e:
        # Send some context about this error to Lambda Logs
        logging.warning("%s" % e)


def lambda_handler(event, context):
    ec2_reccomendations = []
    auto_scaling_group_recommendations= []
    lambda_function_recommendations = []
    ebs_volume_recommendations = []
    Region = os.environ["REGION"]
    print(event)
    try:
        for record in event['Records']:
        
            account_id = record["body"]
            
            print(account_id)
            data = get_ec2_instance_recommendations(account_id, Region)
            ec2_reccomendations.append(data)
            
            auto_data = get_auto_scaling_group_recommendations(account_id, Region)
            auto_scaling_group_recommendations.append(auto_data)

            lambda_data = get_lambda_function_recommendations(account_id, Region)
            lambda_function_recommendations.append(lambda_data)
            
            ebs_data = get_ebs_volume_recommendations(account_id, Region)
            ebs_volume_recommendations.append(ebs_data)

            write_file('ec2_instance_recommendations' ,ec2_reccomendations)
            write_file('auto_scale_recommendations' ,auto_scaling_group_recommendations)
            write_file('lambda_recommendations' ,lambda_function_recommendations)
            write_file('ebs_volume_recommendations' ,ebs_volume_recommendations)

            s3_upload('ec2_instance', Region, account_id)
            s3_upload('auto_scale', Region, account_id)
            s3_upload('lambda', Region, account_id)
            s3_upload('ebs_volume', Region, account_id)

    except Exception as e:
        # Send some context about this error to Lambda Logs
        logging.warning("%s" % e)
