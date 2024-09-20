#!/bin/bash
# Check if all the record file list and corresponding metadata are created. If not, it downloads the list.
# This checks from the start 2019-09-13 up to yestarday (current date -1 day)
#
# Example:
#
# ./check-node-file-lists.sh 0.0.3
#
# Use fix to try downloading the list again:
#
# ./check-node-file-lists.sh 0.0.3 fix
#
# Use ignore-node-join-date if you want to start the check from Hedera public lunch, and not from node starting date
#
# ./check-node-file-lists.sh 0.0.3 fix ignore-node-join-date

# TODO check file existence
source $(dirname "$0")/utils/common.sh

# Check parameters
test -z "$1" && echo "Specify a node ID as first parameter (i.e. 0.0.3)" && exit 100
NODE_ID="$1"

# if the value of the second parameter is "fix", the script try to download file list if missing. Default: false
FIX_IF_MISSING="false"
test "$2" == "fix" && FIX_IF_MISSING="true"

# By default, start date dependes on the date of joining the Governing Council.
# Set the third parameter to "ignore-node-join-date" to start from the Hedera Mainnet lunch day
CHECK_DATE=${HD_NODES_START_DATE[$NODE_ID]}
test "$3" == "ignore-node-join-date" && CHECK_DATE=$HD_HEDERA_MAINNET_START_DATE
test -z "$CHECK_DATE" && echo "Node $NODE_ID didn't start operations yet" && exit 100

TODAY=$(date -I -u) # This is in UTC because Hedera uses UTC, so maybe it's still not tomorrow for Hedera ;)
NODE_FILE_LIST_FOLDER="$HD_LISTS_ROOT_FOLDER/$NODE_ID"

echo "$(print_timestamp) ⚑ Started $0 (PID $$) with the following configuration"
echo "$(print_timestamp) ⛶ Fix list if missing or incomplete ...: $FIX_IF_MISSING"
echo "$(print_timestamp) ⛶ Checking from .......................: $CHECK_DATE"
echo "$(print_timestamp) ⛶ Current time (System time zone)......: $(date)"
echo "$(print_timestamp) ⛶ Current time (UTC)...................: $(date -u)"
echo "$(print_timestamp) ⛶ Toady (UTC)..........................: $TODAY"
echo "$(print_timestamp) ⛶ Yesterday (UTC)......................: $(date -I -d "$TODAY - 1 day")"
echo "$(print_timestamp) ⛶ Hedera Mainnet Start Date ...........: $HD_HEDERA_MAINNET_START_DATE"
echo "$(print_timestamp) ⛶ Node ID ........................: $NODE_ID"
echo "$(print_timestamp) ⛶ Node Join Date .................: ${HD_NODES_JOIN_DATE[$NODE_ID]}"
echo "$(print_timestamp) ⛶ Node Start Date ................: ${HD_NODES_START_DATE[$NODE_ID]}"
echo "$(print_timestamp) ⛶ Node's file lists folder .......: $NODE_FILE_LIST_FOLDER"

while [ "$CHECK_DATE" != "$TODAY" ]; do
    # Check if record list file and metadata are present
    LIST_FILE="$NODE_FILE_LIST_FOLDER/$CHECK_DATE$HD_FILE_LIST_EXTENSION"
    LIST_FILE_METADATA="$NODE_FILE_LIST_FOLDER/$CHECK_DATE$HD_FILE_LIST_METADATA_EXTENSION"
    RECORDS_MD5_LIST_FILE="$NODE_FILE_LIST_FOLDER/$CHECK_DATE$HD_RECORDS_LIST_MD5_EXTENSION"
    SIGNATURES_MD5_LIST_FILE="$NODE_FILE_LIST_FOLDER/$CHECK_DATE$HD_SIGNATURES_LIST_MD5_EXTENSION"

    if [[ ! -s "$LIST_FILE" || ! -s "$LIST_FILE_METADATA" || ! -s "$RECORDS_MD5_LIST_FILE" || ! -s "$SIGNATURES_MD5_LIST_FILE" ]]; then
        echo "$(print_timestamp) ⚠ $CHECK_DATE is missing or incomplete"
        test "$FIX_IF_MISSING" == "true" && ./create-single-file-list-by-day.sh $NODE_ID $CHECK_DATE
    fi
        
    CHECK_DATE=$(date -I -d "$CHECK_DATE + 1 day")
done

echo "$(print_timestamp) 🏁 Script $0 (PID $$) ended" &&\
    exit 0
