#!/bin/sh

START_DATE=$1
END_DATE=$2

while [ "$START_DATE" != "$END_DATE" ]; do 
  echo $START_DATE
  START_DATE=$(date -I -d "$START_DATE + 1 day")
done