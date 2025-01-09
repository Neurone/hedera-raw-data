#!/bin/bash
# ./download-record-by-daily-list 0.0.3 2024-01-01

# TODO check file existence
source $(dirname "$0")/utils/common.sh

# Check parameters
test -z "$1" && echo "specify a node ID as first parameter (i.e. 0.0.3)" && exit 100
test -z "$2" && echo "specify a day (i.e. 2024-01-20)" && exit 100

NODE_ID="$1"
DAY="$2"
NODE_FILE_LIST_FOLDER="$HD_LISTS_ROOT_FOLDER/$NODE_ID"
NODE_SIGNATURES_FOLDER="$HD_SIGNATURES_ROOT_FOLDER/$NODE_ID"
NODE_S3_SOURCE_FOLDER="$HD_S3_RECORD_SOURCE_FOLDER/record$NODE_ID"
NODE_SIGNATURE_DESTINATION_FOLDER="$NODE_SIGNATURES_FOLDER/$DAY"

echo "$(print_timestamp) ⚑ Started $0 (PID $$) with the following configuration"
echo "$(print_timestamp) ⛶ Day (UTC) ............................: $DAY"
echo "$(print_timestamp) ⛶ Node ID .........................: $NODE_ID"
echo "$(print_timestamp) ⛶ Node's file lists folder ........: $NODE_FILE_LIST_FOLDER"
echo "$(print_timestamp) ⛶ Node's signatures destination ...: $NODE_SIGNATURE_DESTINATION_FOLDER"

init_working_folders

create_folder_if_not_present $NODE_SIGNATURE_DESTINATION_FOLDER

#TODO check parameters
#   file sorgente esiste

# verifica se ci sono già dei file scaricati, nel caso riparte da lì
LAST_SIGNATURE_FILE=$(find $NODE_SIGNATURE_DESTINATION_FOLDER -type f -name "$DAYT*" -printf "%f\n" | sort | tail -n1)

if [ -z "$LAST_SIGNATURE_FILE" ]; then
    # Start from the top of the list
    echo "$(print_timestamp) ☕ Downloading signature files from S3 record folder for node $NODE_ID on $DAY"
    cat $NODE_FILE_LIST_FOLDER/$DAY$HD_SIGNATURES_LIST_MD5_EXTENSION |\
        cut -d' ' -f2 |\
        xargs -I {} aws s3api get-object --bucket hedera-testnet-streams-2024-02 --request-payer requester --key $NODE_S3_SOURCE_FOLDER/{} $NODE_SIGNATURE_DESTINATION_FOLDER/{} --no-cli-pager --output text
        #xargs -I {} aws s3 cp s3://hedera-testnet-streams-2024-02/$NODE_S3_SOURCE_FOLDER/{} $NODE_SIGNATURE_DESTINATION_FOLDER --request-payer requester --no-paginate --output text
else
    # Continue downloading again the last file (included, because in case of errors during the download the last file could be corrupted)
    echo "$(print_timestamp) ☕ Continuing download of signature files from S3 record folder for node $NODE_ID on $DAY, starting from $LAST_SIGNATURE_FILE"
    cat $NODE_FILE_LIST_FOLDER/$DAY$HD_SIGNATURES_LIST_MD5_EXTENSION |\
        cut -d' ' -f2 |\
        sed '1,/'$LAST_SIGNATURE_FILE'/d' |\
        sed -e '1i'$LAST_SIGNATURE_FILE |\
        xargs -I {} aws s3api get-object --bucket hedera-testnet-streams-2024-02 --request-payer requester --key $NODE_S3_SOURCE_FOLDER/{} $NODE_SIGNATURE_DESTINATION_FOLDER/{} --no-cli-pager --output text
        #xargs -I {} aws s3 cp s3://hedera-testnet-streams-2024-02/$NODE_S3_SOURCE_FOLDER/{} $NODE_SIGNATURE_DESTINATION_FOLDER --request-payer requester --no-paginate --output text
fi

echo "$(print_timestamp) ✔ Download operations ended"

check_md5sum_list_over_folder $NODE_RECORD_DESTINATION_FOLDER $NODE_FILE_LIST_FOLDER/$DAY$HD_RECORDS_LIST_MD5_EXTENSION

echo "$(print_timestamp) 🏁 Script $0 (PID $$) ended" &&\
    exit 0
