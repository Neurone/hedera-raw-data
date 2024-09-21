#!/bin/bash
# ./create-metadata-from-file-list-by-mirror-node.sh 0 200000

# TODO check file existence
source $(dirname "$0")/utils/common.sh

# Check parameters
test -z "$1" && echo "Specify the first block number (i.e. 0) as first parameter" && exit 100
test -z "$2" && echo "Specify the last block number (i.e. 1000) as second parameter" && exit 100

NODE_ID="mirror-node"
NODE_BLOCK_FILE_LIST_FOLDER="$HD_LISTS_ROOT_FOLDER/$NODE_ID/blocks"
NODE_FILE_LIST_FOLDER="$HD_LISTS_ROOT_FOLDER/$NODE_ID"
FROM_BLOCK=$1
MAX_BLOCK=$2
BLOCKS_PER_FILE=100000  # Multiple of 100

echo "$(print_timestamp) ⚑ Started $0 (PID $$) with the following configuration"
echo "$(print_timestamp) ⛶ Node ID ..........................: $NODE_ID"
echo "$(print_timestamp) ⛶ From block .......................: $FROM_BLOCK"
echo "$(print_timestamp) ⛶ To block .........................: $MAX_BLOCK"
echo "$(print_timestamp) ⛶ Max blocks per file ..............: $BLOCKS_PER_FILE"
echo "$(print_timestamp) ⛶ Node's block file lists folder ...: $NODE_BLOCK_FILE_LIST_FOLDER"
echo "$(print_timestamp) ⛶ Node's file lists folder .........: $NODE_FILE_LIST_FOLDER"

extract_sha384_for_records_from_list    

echo "$(print_timestamp) 🏁 Script $0 (PID $$) ended" &&\
    exit 0
