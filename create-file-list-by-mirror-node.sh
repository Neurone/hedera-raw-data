#!/bin/bash
# Create the file list to download using mirror node's API from start block to last block (excluded)
#
# Example:
#
# ./create-file-lists-by-mirror-node.sh 0 100000
#
# example get blocks between 100 and 105
# https://mainnet.mirrornode.hedera.com/api/v1/blocks?limit=100&order=asc&block.number=gt:99&block.number=lte:105


# TODO check file existence
source $(dirname "$0")/utils/common.sh

# Check parameters
test -z "$1" && echo "Specify the first block number (i.e. 0) as first parameter" && exit 100
test -z "$2" && echo "Specify the last block number (i.e. 1000) as second parameter" && exit 100
FORCE_DOWNLOAD="false"
test "$3" == "overwrite-if-present" && FORCE_DOWNLOAD="true"

NODE_ID="mirror-node"
NODE_BLOCK_FILE_LIST_FOLDER="$HD_LISTS_ROOT_FOLDER/$NODE_ID/blocks"
FROM_BLOCK=$1
MAX_BLOCK=$2
BLOCKS_PER_FILE=100000  # Multiple of 100

echo "$(print_timestamp) ⚑ Started $0 (PID $$) with the following configuration"
echo "$(print_timestamp) ⛶ Node ID ..........................: $NODE_ID"
echo "$(print_timestamp) ⛶ From block .......................: $FROM_BLOCK"
echo "$(print_timestamp) ⛶ To block .........................: $MAX_BLOCK"
echo "$(print_timestamp) ⛶ Max blocks per file ..............: $BLOCKS_PER_FILE"
echo "$(print_timestamp) ⛶ Node's block file lists folder ...: $NODE_BLOCK_FILE_LIST_FOLDER"
echo "$(print_timestamp) ⛶ Force download ...................: $FORCE_DOWNLOAD"

init_working_folders

search_record_list_by_mirror_node

echo "$(print_timestamp) 🏁 Script $0 (PID $$) ended" &&\
    exit 0
