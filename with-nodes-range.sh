#!/bin/bash
# Apply an operation to the set of selected nodes
# Example:
#
# ./with-nodes-range.sh 3 34 download-and-check-signatures-by-md5sum-list.sh 2024-09-18
#
# TODO check file existence
source $(dirname "$0")/utils/common.sh

# Check parameters
test -z "$1" && echo "Specify the first node as first parameter (i.e., 3)" && exit 100
test -z "$2" && echo "Specify the last node as second parameter (i.e., 34)" && exit 100
test -z "$3" && echo "Specify a command that accept a node ID as first parameter. Omit the node parameter (i.e., download-and-check-signatures-by-md5sum-list.sh 2024-01-01)" && exit 100

FIRST_NODE=$1
LAST_NODE=$2
COMMAND=$3

FOLDER_FRIENDLY_TIMESTAMP=$(print_timestamp_folder_friendly)
LOGGING_FOLDER="$HD_LOGGING_FOLDER/$FOLDER_FRIENDLY_TIMESTAMP-with-nodes-range-$FIRST_NODE-$LAST_NODE"

echo "$(print_timestamp) ⚑ Started $0 (PID $$) with the following configuration"
echo "$(print_timestamp) ⛶ Logs folder .............: $LOGGING_FOLDER"
echo "$(print_timestamp) ⛶ Logs files format .......: 0.0.<NODE_ID>.log"
echo "$(print_timestamp) ⛶ Monitor all logs with ...: tail -f $LOGGING_FOLDER/*"
echo "$(print_timestamp) ⛶ Command .................: $COMMAND <0.0.NODE_ID> $@ > $LOGGING_FOLDER/<0.0.NODE_ID>.log &" 

init_working_folders

create_folder_if_not_present $LOGGING_FOLDER

echo "$(print_timestamp) ⚙ Executing command for each nodes from 0.0.$FIRST_NODE to 0.0.$LAST_NODE"

shift 3
for NODE_ID in $(seq $FIRST_NODE $LAST_NODE)
do
	$COMMAND 0.0.$NODE_ID $@ > $LOGGING_FOLDER/0.0.$NODE_ID.log &
done

echo "$(print_timestamp) ☕ Waiting for all the processes to finish. Closing this script does not stop the sub processes."
wait 

echo "$(print_timestamp) 🏁 Script $0 (PID $$) ended" &&\
    exit 0