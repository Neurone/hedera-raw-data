#!/bin/bash
# i.e., ./download-file.sh recordstreams/record0.0.15/2024-01-24T00_00_08.001730738Z.rcd_sig /tmp/foo.rcd_sig
# TODO check file existence
source $(dirname "$0")/utils/common.sh

REMOTE_AWS_S3_FILE=$1
LOCAL_FILE=$2
FORCE_DOWNLOAD="false"
test "$3" == "overwrite-if-present" && FORCE_DOWNLOAD="true"

[ $FORCE_DOWNLOAD == "true" ] || [ ! -s "${LOCAL_FILE}" ] &&\
    download_file_from_aws_s3 $REMOTE_AWS_S3_FILE $LOCAL_FILE
    