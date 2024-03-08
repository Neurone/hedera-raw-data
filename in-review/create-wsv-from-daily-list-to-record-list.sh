#!/bin/sh
DATE=$1
echo "Converting $DATE.list -> $DATE.record.wsv"
jq -c '[.Key, .ETag, .Size]' list/$DATE.list | \
    sed 's/["\\[]//g' | sed 's/.$//' | sed 's/recordstreams\/record0.0.3\///' | sed 's/,/ /g' | \
    sed -e '1iFILENAME MD5 BYTES' | \
    grep -v _sig | \
    uconv --add-signature -o list/$DATE.record.wsv
