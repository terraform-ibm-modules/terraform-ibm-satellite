#!/bin/bash

echo "************* Deleting Hosts *****************"

loc_id=$(ibmcloud sat location ls 2>&1 | grep -m 1 $LOCATION | awk '{print $2}')
hostname=$(echo $hostname | cut -d'.' -f1)
host_id=$(ibmcloud sat host ls --location $loc_id | grep "$hostname" | cut -d' ' -f4)
ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP
ibmcloud sat host rm --location $loc_id --host $host_id -f
