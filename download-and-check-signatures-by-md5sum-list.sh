#!/bin/bash
# ./download-and-check-signatures-by-md5sum-list 0.0.3 2024-01-01

# TODO check file existence
source $(dirname "$0")/utils/common.sh

# Check parameters
test -z "$1" && echo "specify a validator ID (i.e. 0.0.3) as first parameter" && exit 100
test -z "$2" && echo "specify a day (i.e. 2024-01-20) as second parameter" && exit 100

VALIDATOR_ID="$1"
DAY="$2"
# if value is "randomize" than the script will download check and download file in random order, useful to run multiple processes on the same list
RANDOMIZE_FILE_ORDER="false"
test "$3" == "randomize" && RANDOMIZE_FILE_ORDER="true"

VALIDATOR_FILE_LIST_FOLDER="$HD_LISTS_ROOT_FOLDER/$VALIDATOR_ID"
VALIDATOR_SIGNATURES_FOLDER="$HD_SIGNATURES_ROOT_FOLDER/$VALIDATOR_ID"
VALIDATOR_S3_SOURCE_FOLDER="$HD_S3_RECORD_SOURCE_FOLDER/record$VALIDATOR_ID"
VALIDATOR_SIGNATURES_DESTINATION_FOLDER="$VALIDATOR_SIGNATURES_FOLDER/$DAY"
MD5_FILE_LIST=$VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_SIGNATURES_LIST_MD5_EXTENSION

echo "$(print_timestamp) ⚑ Started $0 (PID $$) with the following configuration"
echo "$(print_timestamp) ⛶ Day (UTC) ............................: $DAY"
echo "$(print_timestamp) ⛶ Validator ID .........................: $VALIDATOR_ID"
echo "$(print_timestamp) ⛶ Randomize file order..................: $RANDOMIZE_FILE_ORDER"
echo "$(print_timestamp) ⛶ Validator's file lists folder ........: $VALIDATOR_FILE_LIST_FOLDER"
echo "$(print_timestamp) ⛶ Validator's signatures destination ...: $VALIDATOR_SIGNATURES_DESTINATION_FOLDER"
echo "$(print_timestamp) ⛶ MD5 file list ........................: $MD5_FILE_LIST"

init_working_folders

create_folder_if_not_present $VALIDATOR_SIGNATURES_DESTINATION_FOLDER

FILE_LIST_FULLPATH=$VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_SIGNATURES_FILENAME_LIST_EXTENSION

# TODO check file sorgente esiste
if [ $RANDOMIZE_FILE_ORDER == "true" ]; then
    FILE_LIST_FULLPATH="$FILE_LIST_FULLPATH.$$.random.temp"
    echo "$(print_timestamp) ⚙ Creating list of files in $FILE_LIST_FULLPATH randomizing order from MD5 file list"
    cat $MD5_FILE_LIST | cut -d' ' -f2 | sort -R > $FILE_LIST_FULLPATH
else
    echo "$(print_timestamp) ⚙ Creating list of files in $FILE_LIST_FULLPATH using original ordering from MD5 file list"
    cat $MD5_FILE_LIST | cut -d' ' -f2 > $FILE_LIST_FULLPATH
fi

echo "$(print_timestamp) ☕ Downloading the signature files listed in the MD5 list but missing from the validator's folder"

while IFS= read -r f; do
    if [[ ! -s $VALIDATOR_SIGNATURES_DESTINATION_FOLDER/$f ]]; then
        download_file_from_aws_s3 $VALIDATOR_S3_SOURCE_FOLDER/$f $VALIDATOR_SIGNATURES_DESTINATION_FOLDER/$f
    fi
done < "$FILE_LIST_FULLPATH"

echo "$(print_timestamp) ✔ Download operations ended"

check_md5sum_list_over_folder $MD5_FILE_LIST $VALIDATOR_SIGNATURES_DESTINATION_FOLDER

echo "$(print_timestamp) 🏁 Script $0 (PID $$) ended" &&\
    exit 0
