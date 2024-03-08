#!/bin/bash
# ./download-and-check-records-by-md5sum-list 0.0.3 2024-01-01

# TODO check file existence
source $(dirname "$0")/utils/common.sh

# Check parameters
test -z "$1" && echo "specify a validator ID as first parameter (i.e. 0.0.3)" && exit 100
test -z "$2" && echo "specify a day (i.e. 2024-01-20)" && exit 100

VALIDATOR_ID="$1"
DAY="$2"
VALIDATOR_FILE_LIST_FOLDER="$HD_LISTS_ROOT_FOLDER/$VALIDATOR_ID"
VALIDATOR_RECORDS_FOLDER="$HD_RECORDS_ROOT_FOLDER/$VALIDATOR_ID"
VALIDATOR_S3_SOURCE_FOLDER="$HD_S3_RECORD_SOURCE_FOLDER/record$VALIDATOR_ID"
VALIDATOR_RECORDS_DESTINATION_FOLDER="$VALIDATOR_RECORDS_FOLDER/$DAY"

echo "$(print_timestamp) ⚑ Started $0 (PID $$) with the following configuration"
echo "$(print_timestamp) ⛶ Day (UTC) .........................: $DAY"
echo "$(print_timestamp) ⛶ Validator ID ......................: $VALIDATOR_ID"
echo "$(print_timestamp) ⛶ Validator's file lists folder .....: $VALIDATOR_FILE_LIST_FOLDER"
echo "$(print_timestamp) ⛶ Validator's records destination ...: $VALIDATOR_RECORDS_DESTINATION_FOLDER"

init_working_folders

create_folder_if_not_present $VALIDATOR_RECORDS_DESTINATION_FOLDER

echo "$(print_timestamp) ☕ Downloading the record files listed in the MD5 list but missing from the validator's folder"

# TODO check file sorgente esiste

cat $VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_RECORDS_LIST_MD5_EXTENSION | cut -d' ' -f2 > $VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_RECORDS_FILENAME_LIST_EXTENSION
while IFS= read -r f; do
    if [[ ! -s $VALIDATOR_RECORDS_DESTINATION_FOLDER/$f ]]; then
        download_file_from_aws_s3 $VALIDATOR_S3_SOURCE_FOLDER/$f $VALIDATOR_RECORDS_DESTINATION_FOLDER/$f
    fi
done < "$VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_RECORDS_FILENAME_LIST_EXTENSION"

echo "$(print_timestamp) ✔ Download operations ended"

check_md5sum_list_over_folder $VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_RECORDS_LIST_MD5_EXTENSION $VALIDATOR_RECORDS_DESTINATION_FOLDER

echo "$(print_timestamp) 🏁 Script $0 (PID $$) ended" &&\
    exit 0
