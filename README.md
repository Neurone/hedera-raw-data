# Hedera raw data

Tools to download, manage and share Hedera raw data

## Script list

|Name | Description |
|-|-|
|check-node-file-lists | Check if all the record file list and corresponding metadata are created. If not, it downloads the list. This checks from the start 2019-09-13 up to yesterday (current date -1 day). Use `fix` parameter in case you want to try to download the list again. |
|create-metadata-from-file-list-by-day | Create metadata from AWS file list for a specific day. |
|create-multiple-file-lists-by-day | Create the file list for a specific day for all consensus nodes. |
|create-single-file-list-by-day | Create a single file list from AWS. |
|download-and-check-records-by-md5sum-list | Download and check record files for a node. |
|download-and-check-signatures-by-md5sum-list | Download and check signature files for a node. |
|download-and-check-sidecars-by-md5sum-list | Download and check sidecar files for a node. |
|download-file | Download a single file from AWS S3 |
|with-nodes-range | Helper script to loop through node ranges. |
|loop-date-range | Helper script to loop through dates. |

## Usage examples

Create file lists and metadata files (used to download the actual data) for all current consensus nodes for one day with:

```zsh
./create-multiple-file-lists-by-day.sh 2024-09-18
```

Example output

```zsh
2024-09-20T12:37:40.313Z-225082 ⚑ Started ./create-multiple-file-lists-by-day.sh (PID 225082) with the following configuration
2024-09-20T12:37:40.313Z-225082 ⛶ Day (UTC) ...............: 2024-09-18
2024-09-20T12:37:40.314Z-225082 ⛶ First node ID ......: 0.0.3
2024-09-20T12:37:40.315Z-225082 ⛶ Last node ID .......: 0.0.34
2024-09-20T12:37:40.315Z-225082 ⛶ Logs folder .............: /media/sf_Hedera/hedera-streams/logs/2024-09-20T12_37_40.312Z-225082-create-single-file-list-by-day-2024-09-18
2024-09-20T12:37:40.316Z-225082 ⛶ Logs files format .......: 0.0.<NODE_ID>.log
2024-09-20T12:37:40.317Z-225082 ⛶ Monitor all logs with ...: tail -f /media/sf_Hedera/hedera-streams/logs/2024-09-20T12_37_40.312Z-225082-create-single-file-list-by-day-2024-09-18/*
2024-09-20T12:37:40.320Z-225082 ✔ Created folder /media/sf_Hedera/hedera-streams/logs/2024-09-20T12_37_40.312Z-225082-create-single-file-list-by-day-2024-09-18
2024-09-20T12:37:40.322Z-225082 ✔ Starting a single processes for each nodes from 0.0.3 to 0.0.34
2024-09-20T12:37:40.325Z-225082 ☕ Waiting for all the processes to finish. Closing this script does not stop the sub processes.
2024-09-20T12:38:41.924Z-225082 🏁 Script ./create-multiple-file-lists-by-day.sh (PID 225082) ended
```

Download actual files with dedicated script.

For example, the following script downloads all the record files from node 0.0.3 for the day 2024-09-19:

```zsh
./download-and-check-records-by-md5sum-list.sh 0.0.3 2024-09-18
```

Example output

```zsh
2024-09-20T12:39:49.815Z-228749 ⚑ Started ./download-and-check-records-by-md5sum-list.sh (PID 228749) with the following configuration
2024-09-20T12:39:49.816Z-228749 ⛶ Day (UTC) .........................: 2024-09-18
2024-09-20T12:39:49.817Z-228749 ⛶ Node ID ......................: 0.0.3
2024-09-20T12:39:49.818Z-228749 ⛶ Node's file lists folder .....: /media/sf_Hedera/hedera-streams/lists/0.0.3
2024-09-20T12:39:49.818Z-228749 ⛶ Node's records destination ...: /media/sf_Hedera/hedera-streams/records/0.0.3/2024-09-18
2024-09-20T12:39:49.826Z-228749 ✔ Created folder /media/sf_Hedera/hedera-streams/records/0.0.3/2024-09-18
2024-09-20T12:39:49.827Z-228749 ☕ Downloading the record files listed in the MD5 list but missing from the node's folder
bytes	1097620	binary/octet-stream	"52645018244e75b8982d41de2b7c2288"	2024-09-18T00:00:06+00:00	COMPLETED	requester	AES256	AoExpkNZAeqZeOKgPK0KYIClgsUjieTN
bytes	874688	binary/octet-stream	"bbe2b15f78689010ee7a3e5102b16950"	2024-09-18T00:00:08+00:00	COMPLETED	requester	AES256	1dUMsQ62gIh80y.x8OKSZvAqtf2bUPwT
bytes	1227287	binary/octet-stream	"a94c2bc713b94643a4d64efdc3dff501"	2024-09-18T00:00:09+00:00	COMPLETED	requester	AES256	l32AegROxF2ltsrZo5gg14bS23UaJ4Am
bytes	1152128	binary/octet-stream	"be21511fc29927db226da67babeba8d1"	2024-09-18T00:00:12+00:00	COMPLETED	requester	AES256	tCqKfS7k_8HmZbbfImhrwYdGe9.CcF4Q
bytes	1170972	binary/octet-stream	"f41411f72d30860537761a5c0beef60e"	2024-09-18T00:00:14+00:00	COMPLETED	requester	AES256	dnzNP.PfnEAB9pkA_JpejYVg2fCReM57
bytes	1259463	binary/octet-stream	"1a66b849d68fef2e4bfb15cd5c3b83d4"	2024-09-18T00:00:16+00:00	COMPLETED	requester	AES256	yvbteE71Z2EaQqWgMItjNtOsjiUC7Vvc
bytes	1214243	binary/octet-stream	"09d8889da6ee349ad76bdd7b03f2f179"	2024-09-18T00:00:18+00:00	COMPLETED	requester	AES256	A3fpR4Uv2M8En60ewNfBrJ2hWIaidh92
bytes	1230140	binary/octet-stream	"e86780ec73eec20274fa4b84baf557e1"	2024-09-18T00:00:20+00:00	COMPLETED	requester	AES256	RhbPzl9uuwvWv4gmQqDIPhXP4_TNmr3B
bytes	1260969	binary/octet-stream	"967ff03fe805e97f2e8045f2d628ff44"	2024-09-18T00:00:23+00:00	COMPLETED	requester	AES256	6QXIkd0lggrDjjRgz47EY7PeU9QUBjAm
bytes	1146352	binary/octet-stream	"b5c4584dc3bc9645e8fc713cb046b8c2"	2024-09-18T00:00:24+00:00	COMPLETED	requester	AES256	g7.FeNGp.AXCvzE35Kq9IO2IdXXOhj07
bytes	1315552	binary/octet-stream	"7fe2be8cb6ce2426be263c8dc39d0433"	2024-09-18T00:00:27+00:00	COMPLETED	requester	AES256	sXIf_p2nCzo1wZw.0iP5bdIPOgYIQ1Mq
...
```

Apply operations to multiple consensus nodes with the `with-nodes-range` script:

```zsh
./with-nodes-range.sh 3 11 ./create-single-file-list-by-day.sh 2024-09-18
```

Example output

```zsh
2024-09-20T12:41:34.648Z-229386 ⚑ Started ./with-nodes-range.sh (PID 229386) with the following configuration
2024-09-20T12:41:34.649Z-229386 ⛶ Logs folder .............: /media/sf_Hedera/hedera-streams/logs/2024-09-20T12_41_34.647Z-229386-with-nodes-range-3-11
2024-09-20T12:41:34.650Z-229386 ⛶ Logs files format .......: 0.0.<NODE_ID>.log
2024-09-20T12:41:34.650Z-229386 ⛶ Monitor all logs with ...: tail -f /media/sf_Hedera/hedera-streams/logs/2024-09-20T12_41_34.647Z-229386-with-nodes-range-3-11/*
2024-09-20T12:41:34.651Z-229386 ⛶ Command .................: ./create-single-file-list-by-day.sh <0.0.NODE_ID> 3 11 ./create-single-file-list-by-day.sh 2024-09-18 > /media/sf_Hedera/hedera-streams/logs/2024-09-20T12_41_34.647Z-229386-with-nodes-range-3-11/<0.0.NODE_ID>.log &
2024-09-20T12:41:34.656Z-229386 ✔ Created folder /media/sf_Hedera/hedera-streams/logs/2024-09-20T12_41_34.647Z-229386-with-nodes-range-3-11
2024-09-20T12:41:34.656Z-229386 ⚙ Executing command for each nodes from 0.0.3 to 0.0.11
2024-09-20T12:41:34.659Z-229386 ☕ Waiting for all the processes to finish. Closing this script does not stop the sub processes.
2024-09-20T12:42:07.638Z-229386 🏁 Script ./with-nodes-range.sh (PID 229386) ended
```

Apply operations to multiple days with the `loop-date-range` script:

```zsh
./utils/loop-date-range.sh 2019-09-13 2019-09-27 | xargs -I {} ./download-and-check-records-by-md5sum-list.sh 0.0.5 {}
```

Example output

```zsh
❯ ./utils/loop-date-range.sh 2019-09-13 2019-09-27 | xargs -I {} ./download-and-check-records-by-md5sum-list.sh 0.0.5 {}
2024-09-20T12:45:19.797Z-230724 ⚑ Started ./download-and-check-records-by-md5sum-list.sh (PID 230724) with the following configuration
2024-09-20T12:45:19.798Z-230724 ⛶ Day (UTC) .........................: 2019-09-13
2024-09-20T12:45:19.799Z-230724 ⛶ Node ID ......................: 0.0.5
2024-09-20T12:45:19.800Z-230724 ⛶ Node's file lists folder .....: /media/sf_Hedera/hedera-streams/lists/0.0.5
2024-09-20T12:45:19.800Z-230724 ⛶ Node's records destination ...: /media/sf_Hedera/hedera-streams/records/0.0.5/2019-09-13
2024-09-20T12:45:19.804Z-230724 ✔ Created folder /media/sf_Hedera/hedera-streams/records/0.0.5/2019-09-13
2024-09-20T12:45:19.805Z-230724 ☕ Downloading the record files listed in the MD5 list but missing from the node's folder
bytes	455	application/octet-stream	"874b534374528255a18f0459f0f4a79e"	2019-09-13T22:46:06+00:00	requester	ipZYloKsa8HNnKwDRADHxALgcJgionp7
bytes	453	application/octet-stream	"0ad15899ec4576886fe10a61354a099c"	2019-09-13T22:46:06+00:00	requester	u1QojP9YlVwUbcvdPl1JXRiyzURNkxgT
bytes	455	application/octet-stream	"9de088e826ca33095ee2e387c8924860"	2019-09-13T22:46:06+00:00	requester	eksBHvM5MRx4QL7s3i9krneRb03_0b2O
...
```

Check if all the record file list and corresponding metadata are created. If not, it downloads the list. This checks from the start 2019-09-13 up to yesterday (current date -1 day).

```zsh
./check-node-file-lists.sh 0.0.3
```

Example output

```zsh
2024-09-20T12:49:06.710Z-233689 ⚑ Started ./check-node-file-lists.sh (PID 233689) with the following configuration
2024-09-20T12:49:06.711Z-233689 ⛶ Fix list if missing or incomplete ...: false
2024-09-20T12:49:06.711Z-233689 ⛶ Checking from .......................: 2019-09-13
2024-09-20T12:49:06.712Z-233689 ⛶ Current time (System time zone)......: Fri Sep 20 02:49:06 PM CEST 2024
2024-09-20T12:49:06.713Z-233689 ⛶ Current time (UTC)...................: Fri Sep 20 12:49:06 PM UTC 2024
2024-09-20T12:49:06.714Z-233689 ⛶ Toady (UTC)..........................: 2024-09-20
2024-09-20T12:49:06.715Z-233689 ⛶ Yesterday (UTC)......................: 2024-09-19
2024-09-20T12:49:06.716Z-233689 ⛶ Hedera Mainnet Start Date ...........: 2019-09-13
2024-09-20T12:49:06.717Z-233689 ⛶ Node ID ........................: 0.0.3
2024-09-20T12:49:06.718Z-233689 ⛶ Node Join Date .................: 2020-05-26
2024-09-20T12:49:06.719Z-233689 ⛶ Node Start Date ................: 2019-09-13
2024-09-20T12:49:06.719Z-233689 ⛶ Node's file lists folder .......: /media/sf_Hedera/hedera-streams/lists/0.0.3
2024-09-20T12:49:07.390Z-233689 ⚠ 2021-05-07 is missing or incomplete
2024-09-20T12:49:07.391Z-233689 ⚠ 2021-05-08 is missing or incomplete
2024-09-20T12:49:07.393Z-233689 ⚠ 2021-05-09 is missing or incomplete
2024-09-20T12:49:07.394Z-233689 ⚠ 2021-05-10 is missing or incomplete
2024-09-20T12:49:08.207Z-233689 ⚠ 2023-04-21 is missing or incomplete
2024-09-20T12:49:08.209Z-233689 ⚠ 2023-04-22 is missing or incomplete
2024-09-20T12:49:08.210Z-233689 ⚠ 2023-04-23 is missing or incomplete
2024-09-20T12:49:08.212Z-233689 ⚠ 2023-04-24 is missing or incomplete
2024-09-20T12:49:08.823Z-233689 🏁 Script ./check-node-file-lists.sh (PID 233689) ended
```

Use `fix` parameter in case you want to try to download the list again.

```zsh
./check-node-file-lists.sh 0.0.3 fix
```

Example output

```zsh
2024-09-20T12:52:24.890Z-238196 ⚑ Started ./check-node-file-lists.sh (PID 238196) with the following configuration
2024-09-20T12:52:24.891Z-238196 ⛶ Fix list if missing or incomplete ...: true
2024-09-20T12:52:24.892Z-238196 ⛶ Checking from .......................: 2019-09-13
2024-09-20T12:52:24.892Z-238196 ⛶ Current time (System time zone)......: Fri Sep 20 02:52:24 PM CEST 2024
2024-09-20T12:52:24.893Z-238196 ⛶ Current time (UTC)...................: Fri Sep 20 12:52:24 PM UTC 2024
2024-09-20T12:52:24.895Z-238196 ⛶ Toady (UTC)..........................: 2024-09-20
2024-09-20T12:52:24.895Z-238196 ⛶ Yesterday (UTC)......................: 2024-09-19
2024-09-20T12:52:24.897Z-238196 ⛶ Hedera Mainnet Start Date ...........: 2019-09-13
2024-09-20T12:52:24.898Z-238196 ⛶ Node ID ........................: 0.0.3
2024-09-20T12:52:24.899Z-238196 ⛶ Node Join Date .................: 2020-05-26
2024-09-20T12:52:24.899Z-238196 ⛶ Node Start Date ................: 2019-09-13
2024-09-20T12:52:24.900Z-238196 ⛶ Node's file lists folder .......: /media/sf_Hedera/hedera-streams/lists/0.0.3
2024-09-20T12:52:25.596Z-238196 ⚠ 2021-05-07 is missing or incomplete
2024-09-20T12:52:25.599Z-238831 ⚑ Started ./create-single-file-list-by-day.sh (PID 238831) with the following configuration
2024-09-20T12:52:25.599Z-238831 ⛶ Day (UTC) .......................: 2021-05-07
2024-09-20T12:52:25.600Z-238831 ⛶ Node ID ....................: 0.0.3
2024-09-20T12:52:25.601Z-238831 ⛶ Node's file lists folder ...: /media/sf_Hedera/hedera-streams/lists/0.0.3
2024-09-20T12:52:25.603Z-238831 ☕ Filtering files for 2021-05-07 and consensus node 0.0.3 from AWS S3
2024-09-20T12:52:27.452Z-238831 ⛔ Requested file recordstreams/record0.0.3/sidecar/2021-05-07 missing from AWS S3. Exiting.
2024-09-20T12:52:27.454Z-238196 ⚠ 2021-05-08 is missing or incomplete
2024-09-20T12:52:27.456Z-238887 ⚑ Started ./create-single-file-list-by-day.sh (PID 238887) with the following configuration
2024-09-20T12:52:27.457Z-238887 ⛶ Day (UTC) .......................: 2021-05-08
2024-09-20T12:52:27.458Z-238887 ⛶ Node ID ....................: 0.0.3
2024-09-20T12:52:27.458Z-238887 ⛶ Node's file lists folder ...: /media/sf_Hedera/hedera-streams/lists/0.0.3
2024-09-20T12:52:27.460Z-238887 ☕ Filtering files for 2021-05-08 and consensus node 0.0.3 from AWS S3
2024-09-20T12:52:29.043Z-238887 ⛔ Requested file recordstreams/record0.0.3/sidecar/2021-05-08 missing from AWS S3. Exiting.
2024-09-20T12:52:29.045Z-238196 ⚠ 2021-05-09 is missing or incomplete
2024-09-20T12:52:29.047Z-238943 ⚑ Started ./create-single-file-list-by-day.sh (PID 238943) with the following configuration
2024-09-20T12:52:29.048Z-238943 ⛶ Day (UTC) .......................: 2021-05-09
2024-09-20T12:52:29.049Z-238943 ⛶ Node ID ....................: 0.0.3
2024-09-20T12:52:29.050Z-238943 ⛶ Node's file lists folder ...: /media/sf_Hedera/hedera-streams/lists/0.0.3
2024-09-20T12:52:29.051Z-238943 ☕ Filtering files for 2021-05-09 and consensus node 0.0.3 from AWS S3
2024-09-20T12:52:30.955Z-238943 ⛔ Requested file recordstreams/record0.0.3/sidecar/2021-05-09 missing from AWS S3. Exiting.
2024-09-20T12:52:30.957Z-238196 ⚠ 2021-05-10 is missing or incomplete
2024-09-20T12:52:30.960Z-238999 ⚑ Started ./create-single-file-list-by-day.sh (PID 238999) with the following configuration
2024-09-20T12:52:30.961Z-238999 ⛶ Day (UTC) .......................: 2021-05-10
2024-09-20T12:52:30.962Z-238999 ⛶ Node ID ....................: 0.0.3
2024-09-20T12:52:30.962Z-238999 ⛶ Node's file lists folder ...: /media/sf_Hedera/hedera-streams/lists/0.0.3
2024-09-20T12:52:30.964Z-238999 ☕ Filtering files for 2021-05-10 and consensus node 0.0.3 from AWS S3
2024-09-20T12:52:32.778Z-238999 ⛔ Requested file recordstreams/record0.0.3/sidecar/2021-05-10 missing from AWS S3. Exiting.
2024-09-20T12:52:33.559Z-238196 ⚠ 2023-04-21 is missing or incomplete
2024-09-20T12:52:33.561Z-239765 ⚑ Started ./create-single-file-list-by-day.sh (PID 239765) with the following configuration
2024-09-20T12:52:33.562Z-239765 ⛶ Day (UTC) .......................: 2023-04-21
2024-09-20T12:52:33.563Z-239765 ⛶ Node ID ....................: 0.0.3
2024-09-20T12:52:33.563Z-239765 ⛶ Node's file lists folder ...: /media/sf_Hedera/hedera-streams/lists/0.0.3
2024-09-20T12:52:33.566Z-239765 ☕ Filtering files for 2023-04-21 and consensus node 0.0.3 from AWS S3
2024-09-20T12:52:35.124Z-239765 ⛔ Requested file recordstreams/record0.0.3/sidecar/2023-04-21 missing from AWS S3. Exiting.
2024-09-20T12:52:35.126Z-238196 ⚠ 2023-04-22 is missing or incomplete
2024-09-20T12:52:35.129Z-239821 ⚑ Started ./create-single-file-list-by-day.sh (PID 239821) with the following configuration
2024-09-20T12:52:35.129Z-239821 ⛶ Day (UTC) .......................: 2023-04-22
2024-09-20T12:52:35.130Z-239821 ⛶ Node ID ....................: 0.0.3
2024-09-20T12:52:35.131Z-239821 ⛶ Node's file lists folder ...: /media/sf_Hedera/hedera-streams/lists/0.0.3
2024-09-20T12:52:35.133Z-239821 ☕ Filtering files for 2023-04-22 and consensus node 0.0.3 from AWS S3
2024-09-20T12:52:37.120Z-239821 ⛔ Requested file recordstreams/record0.0.3/sidecar/2023-04-22 missing from AWS S3. Exiting.
2024-09-20T12:52:37.122Z-238196 ⚠ 2023-04-23 is missing or incomplete
2024-09-20T12:52:37.125Z-239877 ⚑ Started ./create-single-file-list-by-day.sh (PID 239877) with the following configuration
2024-09-20T12:52:37.126Z-239877 ⛶ Day (UTC) .......................: 2023-04-23
2024-09-20T12:52:37.126Z-239877 ⛶ Node ID ....................: 0.0.3
2024-09-20T12:52:37.127Z-239877 ⛶ Node's file lists folder ...: /media/sf_Hedera/hedera-streams/lists/0.0.3
2024-09-20T12:52:37.129Z-239877 ☕ Filtering files for 2023-04-23 and consensus node 0.0.3 from AWS S3
2024-09-20T12:52:38.891Z-239877 ⛔ Requested file recordstreams/record0.0.3/sidecar/2023-04-23 missing from AWS S3. Exiting.
2024-09-20T12:52:38.893Z-238196 ⚠ 2023-04-24 is missing or incomplete
2024-09-20T12:52:38.895Z-239933 ⚑ Started ./create-single-file-list-by-day.sh (PID 239933) with the following configuration
2024-09-20T12:52:38.896Z-239933 ⛶ Day (UTC) .......................: 2023-04-24
2024-09-20T12:52:38.897Z-239933 ⛶ Node ID ....................: 0.0.3
2024-09-20T12:52:38.898Z-239933 ⛶ Node's file lists folder ...: /media/sf_Hedera/hedera-streams/lists/0.0.3
2024-09-20T12:52:38.900Z-239933 ☕ Filtering files for 2023-04-24 and consensus node 0.0.3 from AWS S3
2024-09-20T12:52:40.355Z-239933 ⛔ Requested file recordstreams/record0.0.3/sidecar/2023-04-24 missing from AWS S3. Exiting.
2024-09-20T12:52:40.884Z-238196 ⚠ 2024-08-19 is missing or incomplete
2024-09-20T12:52:40.887Z-240471 ⚑ Started ./create-single-file-list-by-day.sh (PID 240471) with the following configuration
2024-09-20T12:52:40.887Z-240471 ⛶ Day (UTC) .......................: 2024-08-19
2024-09-20T12:52:40.888Z-240471 ⛶ Node ID ....................: 0.0.3
2024-09-20T12:52:40.889Z-240471 ⛶ Node's file lists folder ...: /media/sf_Hedera/hedera-streams/lists/0.0.3
2024-09-20T12:52:40.891Z-240471 ☕ Filtering files for 2024-08-19 and consensus node 0.0.3 from AWS S3
2024-09-20T12:53:12.666Z-240471 ⚙ Creating metadata: /media/sf_Hedera/hedera-streams/lists/0.0.3/2024-08-19.metadata
2024-09-20T12:53:13.026Z-240471 ⚙ Extracting MD5 checksums for records to /media/sf_Hedera/hedera-streams/lists/0.0.3/2024-08-19.records.md5sum
2024-09-20T12:53:13.398Z-240471 ⚙ Extracting MD5 checksums for signatures to /media/sf_Hedera/hedera-streams/lists/0.0.3/2024-08-19.signatures.md5sum
2024-09-20T12:53:13.775Z-240471 ⚙ Extracting MD5 checksums for sidecars to /media/sf_Hedera/hedera-streams/lists/0.0.3/2024-08-19.sidecars.md5sum
2024-09-20T12:53:14.168Z-240471 ⚙ Computing records total size to /media/sf_Hedera/hedera-streams/lists/0.0.3/2024-08-19.records.size
2024-09-20T12:53:14.528Z-240471 ⚙ Computing signatures total size to /media/sf_Hedera/hedera-streams/lists/0.0.3/2024-08-19.signatures.size
2024-09-20T12:53:14.868Z-240471 ⚙ Computing sidecars total size to /media/sf_Hedera/hedera-streams/lists/0.0.3/2024-08-19.sidecars.size
2024-09-20T12:53:15.203Z-240471 🏁 Script ./create-single-file-list-by-day.sh (PID 240471) ended
2024-09-20T12:53:15.204Z-238196 ⚠ 2024-08-20 is missing or incomplete
2024-09-20T12:53:15.207Z-240609 ⚑ Started ./create-single-file-list-by-day.sh (PID 240609) with the following configuration
2024-09-20T12:53:15.207Z-240609 ⛶ Day (UTC) .......................: 2024-08-20
2024-09-20T12:53:15.208Z-240609 ⛶ Node ID ....................: 0.0.3
2024-09-20T12:53:15.209Z-240609 ⛶ Node's file lists folder ...: /media/sf_Hedera/hedera-streams/lists/0.0.3
2024-09-20T12:53:15.210Z-240609 ☕ Filtering files for 2024-08-20 and consensus node 0.0.3 from AWS S3
2024-09-20T12:53:44.276Z-240609 ⚙ Creating metadata: /media/sf_Hedera/hedera-streams/lists/0.0.3/2024-08-20.metadata
2024-09-20T12:53:44.642Z-240609 ⚙ Extracting MD5 checksums for records to /media/sf_Hedera/hedera-streams/lists/0.0.3/2024-08-20.records.md5sum
2024-09-20T12:53:45.023Z-240609 ⚙ Extracting MD5 checksums for signatures to /media/sf_Hedera/hedera-streams/lists/0.0.3/2024-08-20.signatures.md5sum
2024-09-20T12:53:45.405Z-240609 ⚙ Extracting MD5 checksums for sidecars to /media/sf_Hedera/hedera-streams/lists/0.0.3/2024-08-20.sidecars.md5sum
2024-09-20T12:53:45.841Z-240609 ⚙ Computing records total size to /media/sf_Hedera/hedera-streams/lists/0.0.3/2024-08-20.records.size
2024-09-20T12:53:46.190Z-240609 ⚙ Computing signatures total size to /media/sf_Hedera/hedera-streams/lists/0.0.3/2024-08-20.signatures.size
2024-09-20T12:53:46.534Z-240609 ⚙ Computing sidecars total size to /media/sf_Hedera/hedera-streams/lists/0.0.3/2024-08-20.sidecars.size
2024-09-20T12:53:46.870Z-240609 🏁 Script ./create-single-file-list-by-day.sh (PID 240609) ended
2024-09-20T12:53:46.907Z-238196 🏁 Script ./check-node-file-lists.sh (PID 238196) ended
```
