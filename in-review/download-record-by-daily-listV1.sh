#!/bin/sh
# pass a day like 2024-01-01
# ./download-record-by-daily-list 2024-01-01

DAY=$1

# escludo le signature
jq -r ".Key" ./list/$DAY.list | \
    grep -v _sig | \
    xargs -I {} ./download-from-s3.sh {} $DAY
