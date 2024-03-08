#!/bin/bash

# TODO check file existence
source $(dirname "$0")/utils/common.sh

REMOTE_AWS_S3_FILE=hedera-mainnet-streams/$1
LOCAL_FILE=$2
FORCE_DOWNLOAD="false"
test "$3" == "overwrite-if-present" && FORCE_DOWNLOAD="true"

[ $FORCE_DOWNLOAD == "true" ] || [ ! -s "${LOCAL_FILE}" ] &&\
    aws s3 cp s3://$REMOTE_AWS_S3_FILE $LOCAL_FILE --request-payer requester --no-paginate --output text
