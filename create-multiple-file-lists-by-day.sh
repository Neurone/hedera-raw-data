#!/bin/bash
# Download the file list for the day from all the validators

# TODO check file existence
source $(dirname "$0")/utils/common.sh

# Check parameters
test -z "$1" && echo "specify a day (i.e. 2024-01-20) as first parameter" && exit 100

DAY=$1
FOLDER_FRIENDLY_TIMESTAMP=$(print_timestamp_folder_friendly)
LOGGING_FOLDER="$HD_LOGGING_FOLDER/$FOLDER_FRIENDLY_TIMESTAMP-create-single-file-list-by-day-$DAY"

echo "$(print_timestamp) ⚑ Started $0 (PID $$) with the following configuration"
echo "$(print_timestamp) ⛶ Day (UTC) ...........: $DAY"
echo "$(print_timestamp) ⛶ First validator ID ..: 0.0.$HD_FIRST_VALIDATOR_NUMBER_ID"
echo "$(print_timestamp) ⛶ Last validator ID ...: 0.0.$HD_LAST_VALIDATOR_NUMBER_ID"
echo "$(print_timestamp) ⛶ Logs folder .........: $LOGGING_FOLDER"
echo "$(print_timestamp) ⛶ Logs files format ...: 0.0.<VALIDATOR_ID>.log"

init_working_folders

create_folder_if_not_present $LOGGING_FOLDER

echo "$(print_timestamp) ✔ Starting a single processes for each validators from 0.0.$HD_FIRST_VALIDATOR_NUMBER_ID to 0.0.$HD_LAST_VALIDATOR_NUMBER_ID"

for VALIDATOR_ID in $(seq $HD_FIRST_VALIDATOR_NUMBER_ID $HD_LAST_VALIDATOR_NUMBER_ID)
do
  ./create-single-file-list-by-day.sh 0.0.$VALIDATOR_ID $DAY >> $LOGGING_FOLDER/0.0.$VALIDATOR_ID.log &
done

echo "$(print_timestamp) ☕ Waiting for all the processes to finish. Closing this script does not stop the sub processes."
wait

echo "$(print_timestamp) 🏁 Script $0 (PID $$) ended" &&\
    exit 0
