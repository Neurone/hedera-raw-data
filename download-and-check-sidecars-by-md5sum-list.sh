#!/bin/bash
# ./download-and-check-records-by-md5sum-list 0.0.3 2024-01-01

# TODO check file existence
source $(dirname "$0")/utils/common.sh

# Check parameters
test -z "$1" && echo "Specify a node ID (i.e. 0.0.3) as first parameter" && exit 100
test -z "$2" && echo "Specify a day (i.e. 2024-01-20) as second parameter" && exit 100

NODE_ID="$1"
DAY="$2"
NODE_FILE_LIST_FOLDER="$HD_LISTS_ROOT_FOLDER/$NODE_ID"
NODE_RECORDS_FOLDER="$HD_RECORDS_ROOT_FOLDER/$NODE_ID"
NODE_S3_SOURCE_FOLDER="$HD_S3_RECORD_SOURCE_FOLDER/record$NODE_ID"
NODE_RECORDS_DESTINATION_FOLDER="$NODE_RECORDS_FOLDER/$DAY"

echo "$(print_timestamp) ⚑ Started $0 (PID $$) with the following configuration"
echo "$(print_timestamp) ⛶ Day (UTC) .........................: $DAY"
echo "$(print_timestamp) ⛶ Node ID ......................: $NODE_ID"
echo "$(print_timestamp) ⛶ Node's file lists folder .....: $NODE_FILE_LIST_FOLDER"
echo "$(print_timestamp) ⛶ Node's records destination ...: $NODE_RECORDS_DESTINATION_FOLDER"

init_working_folders

create_folder_if_not_present $NODE_RECORDS_DESTINATION_FOLDER

echo "$(print_timestamp) ☕ Downloading the record files listed in the MD5 list but missing from the node's folder"

# TODO check file sorgente esiste

cat $NODE_FILE_LIST_FOLDER/$DAY$HD_RECORDS_LIST_MD5_EXTENSION | cut -d' ' -f2 > $NODE_FILE_LIST_FOLDER/$DAY$HD_RECORDS_FILENAME_LIST_EXTENSION
while IFS= read -r f; do
    if [[ ! -s $NODE_RECORDS_DESTINATION_FOLDER/$f ]]; then
        download_file_from_aws_s3 $NODE_S3_SOURCE_FOLDER/$f $NODE_RECORDS_DESTINATION_FOLDER/$f
    fi
done < "$NODE_FILE_LIST_FOLDER/$DAY$HD_RECORDS_FILENAME_LIST_EXTENSION"

echo "$(print_timestamp) ✔ Download operations ended"

check_md5sum_list_over_folder $NODE_FILE_LIST_FOLDER/$DAY$HD_RECORDS_LIST_MD5_EXTENSION $NODE_RECORDS_DESTINATION_FOLDER

echo "$(print_timestamp) 🏁 Script $0 (PID $$) ended" &&\
    exit 0
