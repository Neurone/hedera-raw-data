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
    create_folder_if_not_present $HD_SIDECARS_ROOT_FOLDER
    create_folder_if_not_present $HD_LISTS_ROOT_FOLDER
    create_folder_if_not_present $HD_IPFS_ROOT_FOLDER
    return 0
}

function create_folder_if_not_present()
{
    [ ! -d "$1" ] && mkdir -p $1 && echo "$(print_timestamp) ✔ Created folder $1"
    return 0
}

# Mandatory input env values: NODE_ID, NODE_FILE_LIST_FOLDER, DAY, HD_FILE_LIST_EXTENSION
function search_record_signature_sidecar_list()
{    
    # TODO check mandatory vars
    S3_BUCKET_PREFIX="recordstreams/record$NODE_ID/$DAY"
    LIST_FULLPATH="$NODE_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_EXTENSION"

    create_folder_if_not_present $NODE_FILE_LIST_FOLDER
        
    echo "$(print_timestamp) ☕ Filtering files for $DAY and consensus node $NODE_ID from AWS S3"

    aws s3api list-objects-v2 --bucket hedera-mainnet-streams --request-payer requester --prefix $S3_BUCKET_PREFIX --output json |\
        jq -c ".Contents[]?" > $LIST_FULLPATH
    
    S3_BUCKET_PREFIX="recordstreams/record$NODE_ID/sidecar/$DAY"

    aws s3api list-objects-v2 --bucket hedera-mainnet-streams --request-payer requester --prefix $S3_BUCKET_PREFIX --output json |\
        jq -c ".Contents[]?" >> $LIST_FULLPATH

    [ ! -s "${LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ Requested file $S3_BUCKET_PREFIX missing from AWS S3. Exiting." && exit 101

    return 0
}

# Mandatory input env values: NODE_ID, NODE_BLOCK_FILE_LIST_FOLDER, FROM_BLOCK, MAX_BLOCK, HD_FILE_LIST_MIRROR_NODE_EXTENSION, HD_MIRROR_NODE_HOST
function search_record_list_by_mirror_node()
{    
    # TODO check mandatory vars

    create_folder_if_not_present $NODE_BLOCK_FILE_LIST_FOLDER

    echo "$(print_timestamp) ☕ Fetching block data from block $FROM_BLOCK to block $MAX_BLOCK from mirror node $HD_MIRROR_NODE_HOST"

    MAX_RUNS=$(($BLOCKS_PER_FILE / 100))
    CURRENT_BLOCK=$FROM_BLOCK
    TO_BLOCK=$(($FROM_BLOCK+$BLOCKS_PER_FILE-1))
    while :
    do
        LIST_FULLPATH="$NODE_BLOCK_FILE_LIST_FOLDER/blocks-$CURRENT_BLOCK-$TO_BLOCK$HD_FILE_LIST_MIRROR_NODE_EXTENSION"
        # Don't overwrite existing list, unless FORCE_DOWNLOAD is != false
        [ $FORCE_DOWNLOAD == "false" ] && [ -s "${LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ File $LIST_FULLPATH already exists. Exiting." && exit 102

        # Start from empty file
        echo -n > $LIST_FULLPATH

        for ((CURRENT_BLOCK=$FROM_BLOCK; CURRENT_BLOCK+100 <= $MAX_BLOCK; CURRENT_BLOCK=CURRENT_BLOCK+100 ));
        do
            RUNS=$(($RUNS+1))
            if [ $RUNS -gt $MAX_RUNS ]; then
                break
            fi
            TO_BLOCK=$(($CURRENT_BLOCK+99))
            curl -s "$HD_MIRROR_NODE_HOST/api/v1/blocks?order=asc&limit=100&block.number=gte:$CURRENT_BLOCK&block.number=lte:$TO_BLOCK" |\
                jq -r '.blocks[] | "\(.count) \(.hapi_version) \(.hash) \(.name) \(.number) \(.previous_hash) \(.size) \(.timestamp.from) \(.timestamp.to) \(.gas_used) \(.logs_bloom)"' >> $LIST_FULLPATH
        done

        RUNS=0
        FROM_BLOCK=$(($TO_BLOCK+1))
        TO_BLOCK=$(($FROM_BLOCK+$BLOCKS_PER_FILE-1))
        if [ $FROM_BLOCK -ge $MAX_BLOCK ]; then
            break
        fi
    done

    return 0
}

# Mandatory input env values: NODE_ID, NODE_FILE_LIST_FOLDER, DAY, HD_FILE_LIST_METADATA_EXTENSION
function create_medatada_from_list()
{
    #TODO CHECK VARIABLES
    FILE_LIST_FULLPATH="$NODE_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_EXTENSION"
    METADATA_FULLPATH="$NODE_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_METADATA_EXTENSION"

    # Check FILE_LIST_FULLPATH's size > 0
    [ ! -s "${FILE_LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ File list $FILE_LIST_FULLPATH is empty! A previous download may have been failed. Exiting." && exit 103

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

# Mandatory input env values: NODE_ID, ...
function extract_md5_for_records_from_list()
{
    #TODO CHECK VARIABLES
    FILE_LIST_FULLPATH="$NODE_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_EXTENSION"
    MD5_FULLPATH="$NODE_FILE_LIST_FOLDER/$DAY$HD_RECORDS_LIST_MD5_EXTENSION"

    # Check FILE_LIST_FULLPATH's size > 0
    [ ! -s "${FILE_LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ File list $FILE_LIST_FULLPATH is empty! A previous download may have been failed. Exiting." && exit 104

    echo "$(print_timestamp) ⚙ Extracting MD5 checksums for records to $MD5_FULLPATH"
    jq -c '[.ETag, .Key]' $FILE_LIST_FULLPATH |\
        sed 's/["\\[]//g' | sed 's/.$//' | sed 's/recordstreams\/record'$NODE_ID'\///' | sed 's/,/ /g' |\
        grep -v _sig | grep -v sidecar > $MD5_FULLPATH

    return 0
}

# Mandatory input env values: NODE_ID, ...
function extract_md5_for_signatures_from_list()
{
    #TODO CHECK VARIABLES
    FILE_LIST_FULLPATH="$NODE_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_EXTENSION"
    MD5_FULLPATH="$NODE_FILE_LIST_FOLDER/$DAY$HD_SIGNATURES_LIST_MD5_EXTENSION"

    # Check FILE_LIST_FULLPATH's size > 0
    [ ! -s "${FILE_LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ File list $FILE_LIST_FULLPATH is empty! A previous download may have been failed. Exiting." && exit 105

    echo "$(print_timestamp) ⚙ Extracting MD5 checksums for signatures to $MD5_FULLPATH"
    jq -c '[.ETag, .Key]' $FILE_LIST_FULLPATH |\
        sed 's/["\\[]//g' | sed 's/.$//' | sed 's/recordstreams\/record'$NODE_ID'\///' | sed 's/,/ /g' |\
        grep _sig > $MD5_FULLPATH

    return 0
}

# Mandatory input env values: NODE_ID, ...
function extract_md5_for_sidecars_from_list()
{
    #TODO CHECK VARIABLES
    FILE_LIST_FULLPATH="$NODE_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_EXTENSION"
    MD5_FULLPATH="$NODE_FILE_LIST_FOLDER/$DAY$HD_SIDECARS_LIST_MD5_EXTENSION"

    # Check FILE_LIST_FULLPATH's size > 0
    [ ! -s "${FILE_LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ File list $FILE_LIST_FULLPATH is empty! A previous download may have been failed. Exiting." && exit 106

    echo "$(print_timestamp) ⚙ Extracting MD5 checksums for sidecars to $MD5_FULLPATH"
    jq -c '[.ETag, .Key]' $FILE_LIST_FULLPATH |\
        sed 's/["\\[]//g' | sed 's/.$//' | sed 's/recordstreams\/record'$NODE_ID'\///' | sed 's/,/ /g' |\
        grep sidecar > $MD5_FULLPATH

    return 0
}

# Mandatory input env values: NODE_ID, ...
function extract_sha384_for_records_from_list()
{
    echo "$(print_timestamp) ☕ Extracting SHA384 and record file name from block $FROM_BLOCK to block $MAX_BLOCK"

    MAX_RUNS=$(($BLOCKS_PER_FILE / 100))
    CURRENT_BLOCK=$FROM_BLOCK
    TO_BLOCK=$(($FROM_BLOCK+$BLOCKS_PER_FILE-1))
    declare -a DAYS=()
    while :
    do
        FILE_LIST_FULLPATH="$NODE_BLOCK_FILE_LIST_FOLDER/blocks-$CURRENT_BLOCK-$TO_BLOCK$HD_FILE_LIST_MIRROR_NODE_EXTENSION"
        # Check FILE_LIST_FULLPATH's size > 0
        [ ! -s "${FILE_LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ File list $FILE_LIST_FULLPATH is empty! A previous download may have been failed. Exiting." && exit 104

        echo "$(print_timestamp) ⚙ Extracting SHA384 and record filename from $FILE_LIST_FULLPATH"

        while IFS=' ' read -r _ _ hash_value filename _; do
            # Extract date from filename
            date=$(echo "$filename" | cut -d'T' -f1)
            # Record computed unique days
            if [ ! "$date" == "$last_date" ]; then
                DAYS+=($date)
                echo "$(print_timestamp) ⚙ Extracting date $date"
            fi
            last_date=$date
            SHA384_FULLPATH="$NODE_FILE_LIST_FOLDER/${date}.records.sha384"
            # Append hash and filename to the appropriate file
            echo "$hash_value $filename" >> "$SHA384_FULLPATH"
        done < "$FILE_LIST_FULLPATH"

        # Next batch
        CURRENT_BLOCK=$(($CURRENT_BLOCK+$BLOCKS_PER_FILE))
        FROM_BLOCK=$(($TO_BLOCK+1))
        TO_BLOCK=$(($FROM_BLOCK+$BLOCKS_PER_FILE-1))
        if [ $FROM_BLOCK -ge $MAX_BLOCK ]; then
            break
        fi
    done

    # Sort the content of each generate file by record filename and remove duplicated lines
    for day in "${DAYS[@]}"; do
        filename=$NODE_FILE_LIST_FOLDER/$day.records.sha384
        echo "$(print_timestamp) ⚙ Reordering and cleaning SHA384 and record list files in $filename"
        sort -u -k2,2 -o "$filename" "$filename"
    done

    return 0
}

# Mandatory input env values: NODE_FILE_LIST_FOLDER
function clean_and_order_sha384_record_lists()
{
    echo "$(print_timestamp) ⚙ Reordering and cleaning all SHA384 and record list files from $NODE_FILE_LIST_FOLDER"
    # Sort each output file by timestamp while preserving field order
    for day_file in $NODE_FILE_LIST_FOLDER/*.records.sha384; do
        # Sort each output file by filename and remove duplicated lines
        sort -u -k2,2 -o "$day_file" "$day_file"
    done
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

# Expected 2 parameters, the folder of the file to check and the list to check
function check_sha384sum_list_over_folder()
{
    #TODO CHECK VARIABLES
    SHA384_FULLPATH=$1
    FILE_FOLDER=$2
    FILE_FOLDER_ESCAPE=$(echo $FILE_FOLDER | sed "s/\//\\\\\//g")

    echo "$(print_timestamp) ⚙ Checking SHA384 checksum for files in $SHA384_FULLPATH over $FILE_FOLDER"
    sed 's/ / '$FILE_FOLDER_ESCAPE'\//' $SHA384_FULLPATH | sha384sum -c --status
    if [ $? == 0 ]; then
        echo "$(print_timestamp) ✔ All the listed files match with the files in the folder."
    else
        echo "$(print_timestamp) ⚠ Errors during the verification of the SHA384 checksums. Check the logs for details"
        sed 's/ / '$FILE_FOLDER_ESCAPE'\//' $SHA384_FULLPATH | sha384sum -c --quiet
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


# Mandatory input env values: NODE_ID, ...
function extract_size_for_records_from_list()
{
    #TODO CHECK VARIABLES
    FILE_LIST_FULLPATH="$NODE_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_EXTENSION"
    SIZE_FULLPATH="$NODE_FILE_LIST_FOLDER/$DAY$HD_RECORDS_LIST_SIZE_EXTENSION"

    [ ! -s "${FILE_LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ File list $FILE_LIST_FULLPATH is empty! A previous download may have been failed. Exiting." && exit 107

    echo "$(print_timestamp) ⚙ Computing records total size to $SIZE_FULLPATH"
    jq -c "[.Size, .Key]" $FILE_LIST_FULLPATH |\
        grep -v _sig | sed 's/\[//g' | sed 's/,.*//g'| paste -s -d+ - |\
        bc > $SIZE_FULLPATH

    return 0
}

# Mandatory input env values: NODE_ID, ...
function extract_size_for_signatures_from_list()
{
    #TODO CHECK VARIABLES
    FILE_LIST_FULLPATH="$NODE_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_EXTENSION"
    SIZE_FULLPATH="$NODE_FILE_LIST_FOLDER/$DAY$HD_SIGNATURES_LIST_SIZE_EXTENSION"

    [ ! -s "${FILE_LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ File list $FILE_LIST_FULLPATH is empty! A previous download may have been failed. Exiting." && exit 108

    echo "$(print_timestamp) ⚙ Computing signatures total size to $SIZE_FULLPATH"
    jq -c "[.Size, .Key]" $FILE_LIST_FULLPATH |\
        grep _sig | sed 's/\[//g' | sed 's/,.*//g'| paste -s -d+ - |\
        bc > $SIZE_FULLPATH

    return 0
}

# Mandatory input env values: NODE_ID, ...
function extract_size_for_sidecars_from_list()
{
    #TODO CHECK VARIABLES
    FILE_LIST_FULLPATH="$NODE_FILE_LIST_FOLDER/$DAY$HD_FILE_LIST_EXTENSION"
    SIZE_FULLPATH="$NODE_FILE_LIST_FOLDER/$DAY$HD_SIDECARS_LIST_SIZE_EXTENSION"

    [ ! -s "${FILE_LIST_FULLPATH}" ] && echo "$(print_timestamp) ⛔ File list $FILE_LIST_FULLPATH is empty! A previous download may have been failed. Exiting." && exit 109

    echo "$(print_timestamp) ⚙ Computing sidecars total size to $SIZE_FULLPATH"
    jq -c "[.Size, .Key]" $FILE_LIST_FULLPATH |\
        grep sidecar | sed 's/\[//g' | sed 's/,.*//g'| paste -s -d+ - |\
        bc > $SIZE_FULLPATH

    return 0
}
