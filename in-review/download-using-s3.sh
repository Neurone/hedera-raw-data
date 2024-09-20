#!/bin/sh
S3_SOURCE_FILENAME=$1
S3_SOURCE_FOLDER=$2
S3_SOURCE_FULLPATH="$S3_SOURCE_FOLDER/$S3_SOURCE_FILENAME"
NODE_RECORDS_FOLDER=$3
BUCKET_NAME="hedera-mainnet-streams"

aws s3 cp s3://$BUCKET_NAME/$S3_SOURCE_FULLPATH $NODE_RECORDS_FOLDER/ --request-payer requester --no-paginate --output text
