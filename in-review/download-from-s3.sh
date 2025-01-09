#!/bin/sh
FILEPATH=$1
DAY=$2

aws s3api get-object --bucket hedera-testnet-streams-2024-02 --request-payer requester --key $FILEPATH ./records/$FILENAME --no-cli-pager --output text

