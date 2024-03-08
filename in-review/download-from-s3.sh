#!/bin/sh
FILEPATH=$1
DAY=$2

aws s3api get-object --bucket hedera-mainnet-streams --request-payer requester --key $FILEPATH ./records/$FILENAME --no-cli-pager --output text

