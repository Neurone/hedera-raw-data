#!/bin/bash
# ./create-single-file-list-by-day.sh 0.0.3 2024-01-01

# TODO check file existence
source $(dirname "$0")/utils/common.sh

# Check parameters
test -z "$1" && echo "Specify a node ID (i.e. 0.0.3) as first parameter" && exit 100
test -z "$2" && echo "Specify a day (i.e. 2024-01-20) as second parameter" && exit 100

NODE_ID=$1
NODE_FILE_LIST_FOLDER=$HD_LISTS_ROOT_FOLDER/$NODE_ID
DAY=$2

echo "$(print_timestamp) ⚑ Started $0 (PID $$) with the following configuration"
echo "$(print_timestamp) ⛶ Day (UTC) ..................: $DAY"
echo "$(print_timestamp) ⛶ Node ID ....................: $NODE_ID"
echo "$(print_timestamp) ⛶ Node's file lists folder ...: $NODE_FILE_LIST_FOLDER"

init_working_folders

search_record_signature_sidecar_list &&\
    create_medatada_from_list &&\
    extract_md5_for_records_from_list &&\
    extract_md5_for_signatures_from_list &&\
    extract_md5_for_sidecars_from_list &&\
    extract_size_for_records_from_list &&\
    extract_size_for_signatures_from_list &&\
    extract_size_for_sidecars_from_list

echo "$(print_timestamp) 🏁 Script $0 (PID $$) ended" &&\
    exit 0
