#!/bin/bash
# ./download-records-by-md5sum-list 0.0.3 2024-01-01

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
VALIDATOR_RECORD_DESTINATION_FOLDER="$VALIDATOR_RECORDS_FOLDER/$DAY"

echo "$(print_timestamp) ⚑ Started $0 (PID $$) with the following configuration"
echo "$(print_timestamp) ⛶ Day (UTC) .........................: $DAY"
echo "$(print_timestamp) ⛶ Validator ID ......................: $VALIDATOR_ID"
echo "$(print_timestamp) ⛶ Validator's file lists folder .....: $VALIDATOR_FILE_LIST_FOLDER"
echo "$(print_timestamp) ⛶ Validator's records destination ...: $VALIDATOR_RECORD_DESTINATION_FOLDER"

init_working_folders

create_folder_if_not_present $VALIDATOR_RECORD_DESTINATION_FOLDER

#TODO check parameters
#   file sorgente esiste

# verifica se ci sono già dei file scaricati, nel caso riparte da lì
LAST_RECORD_FILE=$(find $VALIDATOR_RECORD_DESTINATION_FOLDER -type f -name "$DAYT*" -printf "%f\n" | sort | tail -n1)

if [ -z "$LAST_RECORD_FILE" ]; then
    # Start from the top of the list
    echo "$(print_timestamp) ☕ Downloading record files from S3 record folder for validator $VALIDATOR_ID on $DAY"
    cat $VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_RECORDS_LIST_MD5_EXTENSION |\
        cut -d' ' -f2 |\
        xargs -I {} aws s3api get-object --bucket hedera-mainnet-streams --request-payer requester --key $VALIDATOR_S3_SOURCE_FOLDER/{} $VALIDATOR_RECORD_DESTINATION_FOLDER/{} --no-cli-pager --output text
        #xargs -I {} aws s3 cp s3://hedera-mainnet-streams/$VALIDATOR_S3_SOURCE_FOLDER/{} $VALIDATOR_RECORD_DESTINATION_FOLDER --request-payer requester --no-paginate --output text
else
    # Continue downloading again the last file (included, because in case of errors during the download the last file could be corrupted)
    echo "$(print_timestamp) ☕ Continuing download of record files from S3 record folder for validator $VALIDATOR_ID on $DAY, starting from $LAST_RECORD_FILE"
    cat $VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_RECORDS_LIST_MD5_EXTENSION |\
        cut -d' ' -f2 |\
        sed '1,/'$LAST_RECORD_FILE'/d' |\
        sed -e '1i'$LAST_RECORD_FILE |\
        xargs -I {} aws s3api get-object --bucket hedera-mainnet-streams --request-payer requester --key $VALIDATOR_S3_SOURCE_FOLDER/{} $VALIDATOR_RECORD_DESTINATION_FOLDER/{} --no-cli-pager --output text
        #xargs -I {} aws s3 cp s3://hedera-mainnet-streams/$VALIDATOR_S3_SOURCE_FOLDER/{} $VALIDATOR_RECORD_DESTINATION_FOLDER --request-payer requester --no-paginate --output text
fi

echo "$(print_timestamp) ✔ Download operations ended"

check_md5sum_list_over_folder $VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_RECORDS_LIST_MD5_EXTENSION $VALIDATOR_RECORD_DESTINATION_FOLDER

echo "$(print_timestamp) 🏁 Script $0 (PID $$) ended" &&\
    exit 0
