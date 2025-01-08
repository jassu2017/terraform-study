#!/bin/bash

#Fecth AWS credentials  from secret manager
SECRET=$(aws secretsmanager get-secret-value --secret-id my-aws-creds-tf --query SecretString --output text)

#parse the secret key
AWS_ACCESS_KEY_ID=$(echo $SECRET | jq -r '.aws_access_key_id')
AWS_SECRET_ACESS_KEY=$(echo $SECRET | jq -r '.aws_secret_access_key')

#Export as env variables

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACESS_KEY
export AWS_DEFAULT_REGION="ap-south-1"

#Run AWS cli commands

aws s3 ls

