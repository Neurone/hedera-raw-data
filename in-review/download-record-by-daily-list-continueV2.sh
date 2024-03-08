#!/bin/sh
# get a day like 2024-01-01 and continue donwloading from the last file (included, because in case of errors during the download the last file can be corrupted)
# ./download-record-by-daily-list-continue 2024-01-01 

DAY=$1
LAST_FILE=$(find records/recordstreams/record0.0.3 -type f -name "$DAYT*" -printf "%f\n" | sort | tail -n1)

echo "Continuing download from $LAST_FILE (included)"

# escludo le signature
jq -r ".Key" ./list/$1.list | \
    grep -v _sig | \
    sed '1,/'$LAST_FILE'/d' | \
    sed -e '1irecordstreams/record0.0.3/'$LAST_FILE | \
    xargs -I {} ./download-from-s3V2.sh {}
