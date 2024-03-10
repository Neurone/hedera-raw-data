#!/bin/bash
# Check if all the record file list and corresponding metadata are created, or it download the list.
# This checks from the start 2019-09-13 up to yestarday (current date -1 day)

# TODO check file existence
source $(dirname "$0")/utils/common.sh

# Check parameters
test -z "$1" && echo "specify a validator ID as first parameter (i.e. 0.0.3)" && exit 100
VALIDATOR_ID="$1"

# if the value of the second parameter is "fix", the script try to download file list if missing. Default: false
FIX_IF_MISSING="false"
test "$2" == "fix" && FIX_IF_MISSING="true"

# By default, start date dependes on the date of joining the Governing Council.
# Set the third parameter to "ignore-validator-join-date" to start from the Hedera Mainnet lunch day
CHECK_DATE=${HD_VALIDATORS_JOIN_DATE[$VALIDATOR_ID]}
test "$3" == "ignore-validator-join-date" && CHECK_DATE=$HD_HEDERA_MAINNET_START_DATE

TODAY=$(date -I -u) # This is in UTC because Hedera uses UTC, so maybe it's still not tomorrow for Hedera ;)
VALIDATOR_FILE_LIST_FOLDER="$HD_LISTS_ROOT_FOLDER/$VALIDATOR_ID"

echo "$(print_timestamp) ⚑ Started $0 (PID $$) with the following configuration"
echo "$(print_timestamp) ⛶ Fix list if missing or incomplete ...: $FIX_IF_MISSING"
echo "$(print_timestamp) ⛶ Checking from .......................: $CHECK_DATE"
echo "$(print_timestamp) ⛶ Current time (System time zone)......: $(date)"
echo "$(print_timestamp) ⛶ Current time (UTC)...................: $(date -u)"
echo "$(print_timestamp) ⛶ Toady (UTC)..........................: $TODAY"
echo "$(print_timestamp) ⛶ Yesterday (UTC)......................: $(date -I -d "$TODAY - 1 day")"
echo "$(print_timestamp) ⛶ Hedera Mainnet Start Date ...........: $HD_HEDERA_MAINNET_START_DATE"
echo "$(print_timestamp) ⛶ Validator ID ........................: $VALIDATOR_ID"
echo "$(print_timestamp) ⛶ Validator Start Date ................: ${HD_VALIDATORS_JOIN_DATE[$VALIDATOR_ID]}"
echo "$(print_timestamp) ⛶ Validator's file lists folder .......: $VALIDATOR_FILE_LIST_FOLDER"

while [ "$CHECK_DATE" != "$TODAY" ]; do
    # Check if record list file and metadata are present
    LIST_FILE="$VALIDATOR_FILE_LIST_FOLDER/$CHECK_DATE$HD_FILE_LIST_EXTENSION"
    LIST_FILE_METADATA="$VALIDATOR_FILE_LIST_FOLDER/$CHECK_DATE$HD_FILE_LIST_METADATA_EXTENSION"
    RECORDS_MD5_LIST_FILE="$VALIDATOR_FILE_LIST_FOLDER/$CHECK_DATE$HD_RECORDS_LIST_MD5_EXTENSION"
    SIGNATURES_MD5_LIST_FILE="$VALIDATOR_FILE_LIST_FOLDER/$CHECK_DATE$HD_SIGNATURES_LIST_MD5_EXTENSION"

    if [[ ! -s "$LIST_FILE" || ! -s "$LIST_FILE_METADATA" || ! -s "$RECORDS_MD5_LIST_FILE" || ! -s "$SIGNATURES_MD5_LIST_FILE" ]]; then
        echo "$(print_timestamp) ⚠ $CHECK_DATE is missing or incomplete"
        test "$FIX_IF_MISSING" == "true" && ./create-single-file-list-by-day.sh $VALIDATOR_ID $CHECK_DATE
    fi
        
    CHECK_DATE=$(date -I -d "$CHECK_DATE + 1 day")
done

echo "$(print_timestamp) 🏁 Script $0 (PID $$) ended" &&\
    exit 0
