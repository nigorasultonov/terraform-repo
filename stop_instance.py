import boto3
import os

def lambda_handler(event, context):
    ec2 = boto3.client('ec2', region_name='us-east-2')
    instance_ids = [os.environ['i-06d463b8e025d9c75'], os.environ['i-076a121fb843936b7']]
    ec2.stop_instances(InstanceIds=instance_ids)
    print(f"Stopped instances {instance_ids}")