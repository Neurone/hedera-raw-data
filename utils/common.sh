#!/bin/bash
# ☕ ℹ ★ 🚩 🏁 ⚐ ⚑ 🔽 🔼 ↧ ☝ ⛔ ⛶ ➕ + ✓ ✔ ⚠⚙
# This file is meant to be imported with `source` as a library for other bash scripts
source $(dirname "$0")/config   # the path refers to the initial script in the root, not to the common.sh folder

function init_working_folders()
{
    create_folder_if_not_present $HD_ROOT_DATA_FOLDER
    create_folder_if_not_present $HD_LOGGING_FOLDER
    create_folder_if_not_present $HD_RECORDS_ROOT_FOLDER
    create_folder_if_not_present $HD_SIGNATURES_ROOT_FOLDER
    create_folder_if_not_present $HD_LISTS_ROOT_FOLDER
    create_folder_if_not_present $HD_IPFS_ROOT_FOLDER
    return 0
}

function create_folder_if_not_present()
{
    [ ! -d "$1" ] && mkdir -p $1 && echo "$(print_timestamp) ✔ Created folder $1"
    return 0
}

# Mandatory input env values: VALIDATOR_ID, VALIDATOR_FILE_LIST_FOLDER, DAY, HD_FILE_LIST_EXTENSION
function search_record_and_signature_list()
{    
    # TODO check mandatory vars
    S3_BUCKET_PREFIX="recordstreams/record$VALIDATOR_ID/$DAY"
    LIST_FULLPATH="$VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_EXTENSION"

    create_folder_if_not_present $VALIDATOR_FILE_LIST_FOLDER
        
    echo "$(print_timestamp) ☕ Filtering files for $DAY and consensus node $VALIDATOR_ID from AWS S3"
    aws s3api list-objects-v2 --bucket hedera-mainnet-streams --request-payer requester --prefix $S3_BUCKET_PREFIX --output json |\
        jq -c ".Contents[]?" > $LIST_FULLPATH
    
    [ ! -s "${LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ Requested file $S3_BUCKET_PREFIX missing from AWS S3. Exiting." && exit 101

    return 0
}

# Mandatory input env values: VALIDATOR_ID, VALIDATOR_FILE_LIST_FOLDER, DAY, HD_FILE_LIST_METADATA_EXTENSION
function create_medatada_from_list()
{
    #TODO CHECK VARIABLES
    FILE_LIST_FULLPATH="$VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_EXTENSION"
    METADATA_FULLPATH="$VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_METADATA_EXTENSION"

    # Check FILE_LIST_FULLPATH's size > 0
    [ ! -s "${FILE_LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ File list $FILE_LIST_FULLPATH is empty! A previous download may have been failed. Exiting." && exit 102

    echo "$(print_timestamp) ⚙ Creating metadata: $METADATA_FULLPATH"
    # we have one record file + one record signature each 2 seconds, so in total ~86400 elements per day
    # total size of all listed files (record file + signatures)
    # total size in MBytes
    echo "$(wc -l $FILE_LIST_FULLPATH | cut -d' ' -f1) files" > $METADATA_FULLPATH &&\
        FILE_LIST_TOTAL_SIZE=$(jq ".Size" $FILE_LIST_FULLPATH | paste -s -d+ - | bc) &&\
        echo "$FILE_LIST_TOTAL_SIZE total bytes" >> $METADATA_FULLPATH &&\
        echo "$(echo "$FILE_LIST_TOTAL_SIZE / (1024 * 1024)" | bc) total MBytes" >> $METADATA_FULLPATH

    return 0
}

# Mandatory input env values: VALIDATOR_ID, ...
function extract_md5_for_records_from_list()
{
    #TODO CHECK VARIABLES
    FILE_LIST_FULLPATH="$VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_EXTENSION"
    MD5_FULLPATH="$VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_RECORDS_LIST_MD5_EXTENSION"

    # Check FILE_LIST_FULLPATH's size > 0
    [ ! -s "${FILE_LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ File list $FILE_LIST_FULLPATH is empty! A previous download may have been failed. Exiting." && exit 102

    echo "$(print_timestamp) ⚙ Extracting MD5 checksums for records to $MD5_FULLPATH"
    jq -c '[.ETag, .Key]' $FILE_LIST_FULLPATH |\
        sed 's/["\\[]//g' | sed 's/.$//' | sed 's/recordstreams\/record'$VALIDATOR_ID'\///' | sed 's/,/ /g' |\
        grep -v _sig > $MD5_FULLPATH

    return 0
}

# Mandatory input env values: VALIDATOR_ID, ...
function extract_md5_for_signatures_from_list()
{
    #TODO CHECK VARIABLES
    FILE_LIST_FULLPATH="$VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_EXTENSION"
    MD5_FULLPATH="$VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_SIGNATURES_LIST_MD5_EXTENSION"

    # Check FILE_LIST_FULLPATH's size > 0
    [ ! -s "${FILE_LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ File list $FILE_LIST_FULLPATH is empty! A previous download may have been failed. Exiting." && exit 102

    echo "$(print_timestamp) ⚙ Extracting MD5 checksums for signatures to $MD5_FULLPATH"
    jq -c '[.ETag, .Key]' $FILE_LIST_FULLPATH |\
        sed 's/["\\[]//g' | sed 's/.$//' | sed 's/recordstreams\/record'$VALIDATOR_ID'\///' | sed 's/,/ /g' |\
        grep _sig > $MD5_FULLPATH

    return 0
}

# Output in UTC and the current process ID. Example: 2024-01-28T18:49:10.335Z-1234
function print_timestamp()
{
    echo -n $(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")-$$

    return 0
}

# Output in UTC and the current process ID, in a "folder friendly" format. Example: 2024-01-28T18_49_10.335Z-1234
function print_timestamp_folder_friendly()
{
    echo -n $(date -u +"%Y-%m-%dT%H_%M_%S.%3NZ")-$$

    return 0
}

# Expected 2 parameters, the folder of the file to check and the list to check
function check_md5sum_list_over_folder()
{
    #TODO CHECK VARIABLES
    MD5_FULLPATH=$1
    FILE_FOLDER=$2
    FILE_FOLDER_ESCAPE=$(echo $FILE_FOLDER | sed "s/\//\\\\\//g")

    echo "$(print_timestamp) ⚙ Checking MD5 checksum for files in $MD5_FULLPATH over $FILE_FOLDER"
    sed 's/ / '$FILE_FOLDER_ESCAPE'\//' $MD5_FULLPATH | md5sum -c --status
    if [ $? == 0 ]; then
        echo "$(print_timestamp) ✔ All the listed files match with the files in the folder."
    else
        echo "$(print_timestamp) ⚠ Errors during the verification of the MD5 checksums. Check the logs for details"
        #sed 's/ / '$FILE_FOLDER_ESCAPE'\//' $MD5_FULLPATH | md5sum -c --quiet
    fi

    return 0
}

# Expect 2 parameters, source file (full path, excluding bucket name) and destination file (full path)
# i.e., recordstreams/record0.0.3/2024-01-30T00_00_00.005915627Z.rcd_sig /tmp/2024-01-30T00_00_00.005915627Z.rcd_sig
function download_file_from_aws_s3()
{
    # Note: no echo because the aws CLI already output a result
    aws s3api get-object --bucket $HD_S3_BUCKET_NAME --key $1 --request-payer requester $2 --no-cli-pager --output text --no-paginate --no-cli-auto-prompt
    
    return 0
}


# Mandatory input env values: VALIDATOR_ID, ...
function extract_size_for_records_from_list()
{
    #TODO CHECK VARIABLES
    FILE_LIST_FULLPATH="$VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_EXTENSION"
    SIZE_FULLPATH="$VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_RECORDS_LIST_SIZE_EXTENSION"

    [ ! -s "${FILE_LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ File list $FILE_LIST_FULLPATH is empty! A previous download may have been failed. Exiting." && exit 102

    echo "$(print_timestamp) ⚙ Computing records total size to $SIZE_FULLPATH"
    jq -c "[.Size, .Key]" $FILE_LIST_FULLPATH |\
        grep -v _sig | sed 's/\[//g' | sed 's/,.*//g'| paste -s -d+ - |\
        bc > $SIZE_FULLPATH

    return 0
}

# Mandatory input env values: VALIDATOR_ID, ...
function extract_size_for_signatures_from_list()
{
    #TODO CHECK VARIABLES
    FILE_LIST_FULLPATH="$VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_EXTENSION"
    SIZE_FULLPATH="$VALIDATOR_FILE_LIST_FOLDER/$DAY$HD_SIGNATURES_LIST_SIZE_EXTENSION"

    [ ! -s "${FILE_LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ File list $FILE_LIST_FULLPATH is empty! A previous download may have been failed. Exiting." && exit 102

    echo "$(print_timestamp) ⚙ Computing signatures total size to $SIZE_FULLPATH"
    jq -c "[.Size, .Key]" $FILE_LIST_FULLPATH |\
        grep _sig | sed 's/\[//g' | sed 's/,.*//g'| paste -s -d+ - |\
        bc > $SIZE_FULLPATH

    return 0
}