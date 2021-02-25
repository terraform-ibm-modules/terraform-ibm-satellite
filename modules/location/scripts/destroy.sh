#!/bin/bash

echo ************* Deleting location *****************
echo LOCATION= $LOCATION
ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP
n=0
until [ "$n" -ge 5 ]
do
    ibmcloud sat location rm --location $LOCATION -f && break
    echo "************* Failed with $n, waiting to retry *****************"
    n=$((n+1))
    sleep 10
done
rm -rf /tmp/.schematics/addhost.sh