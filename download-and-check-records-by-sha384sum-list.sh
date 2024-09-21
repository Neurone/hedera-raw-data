#!/bin/bash
# Download data trusting the results provided by a mirror node APIs, in particular the /blocks endpoint
# The script download the record file, the corresponding signatures, and the potential sidecar
# Note: signature are downloaded but NOT currently verified
# the only verification is done on the hash of the record file, so if you trust the mirror node to provide the correct hash, you can download the file from another node if the hash does not match (by default files are downloaded from the 0.0.3 folder)

# TODO check file existence
source $(dirname "$0")/utils/common.sh

# Check parameters
test -z "$1" && echo "Specify a day (i.e. 2024-01-20) as first parameter" && exit 100

NODE_ID="mirror-node"
DAY="$1"
NODE_FILE_LIST_FOLDER="$HD_LISTS_ROOT_FOLDER/$NODE_ID"
NODE_RECORDS_FOLDER="$HD_RECORDS_ROOT_FOLDER/$NODE_ID"
NODE_S3_SOURCE_FOLDER="$HD_S3_RECORD_SOURCE_FOLDER/record$NODE_ID"
NODE_RECORDS_DESTINATION_FOLDER="$NODE_RECORDS_FOLDER/$DAY"

echo "$(print_timestamp) ⚑ Started $0 (PID $$) with the following configuration"
echo "$(print_timestamp) ⛶ Day (UTC) ....................: $DAY"
echo "$(print_timestamp) ⛶ Node ID ......................: $NODE_ID"
echo "$(print_timestamp) ⛶ Node's file lists folder .....: $NODE_FILE_LIST_FOLDER"
echo "$(print_timestamp) ⛶ Node's records destination ...: $NODE_RECORDS_DESTINATION_FOLDER"

init_working_folders

create_folder_if_not_present $NODE_RECORDS_DESTINATION_FOLDER

echo "$(print_timestamp) ☕ Downloading the record files listed by the mirror node at $HD_MIRROR_NODE_API"

#download_file_from_aws_s3 $NODE_S3_SOURCE_FOLDER/$f $NODE_RECORDS_DESTINATION_FOLDER/$f

echo "$(print_timestamp) ✔ Download operations ended"

check_sha384sum_list_over_folder $NODE_FILE_LIST_FOLDER/$DAY$HD_RECORDS_LIST_SHA384_EXTENSION $NODE_RECORDS_DESTINATION_FOLDER

echo "$(print_timestamp) 🏁 Script $0 (PID $$) ended" &&\
    exit 0
