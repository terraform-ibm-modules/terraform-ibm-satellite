#!/bin/bash
ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP
ibmcloud iam oauth-tokens
if [ "$PROVIDER" == "aws" ]; then
    hostname=$(echo $hostname | cut -d "." -f 1)
fi
# Check host attached to location 
host_out=`ibmcloud sat host ls --location $LOCATION | grep $hostname`
rc=$?
while [ $rc -eq 1 ]
do
    host_out=`ibmcloud sat host ls --location $LOCATION | grep $hostname`
    HOST_ID=$(echo $host_out| cut -d' ' -f 2)
    if [[ $HOST_ID != "" ]]; then
        echo host $hostname attached
        rc=0
        break
    fi
    echo "************* hosts not attached to location *****************"
    sleep 10
done    
HOST_ID=$(echo $host_out| cut -d' ' -f 2)
if [[ $index == 0 ]]; then
    zone="$host_zone-1"
elif [ $index == 1 ]; then
    zone="$host_zone-2"
else
    zone="$host_zone-3"
fi
echo hostout= $host_out
echo hostid= $HOST_ID
echo hostname= $hostname
echo location= $LOCATION
# Assign host to location control plane
ibmcloud sat host assign --cluster $LOCATION --location $LOCATION --host $HOST_ID --zone $zone
status='notready'
echo $status
while [ "$status" != "ready" ]
do
   if [[ $(ibmcloud sat host ls --location $LOCATION | grep $hostname) == *"Ready"* ]]; then
    echo host $hostname ready
    status="ready"
    break
  fi
    echo "************* hosts not ready *****************"
    sleep 10
done
# echo -n "{\"assign_output\":\"${asout}\"}"