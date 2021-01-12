#!/bin/bash

# function check_deps() {
#   test -f $(which jq) || error_exit "jq command not detected in path, please install it"
# }

# eval "$(jq -r '@sh "hostname=\(.host) count=\(.ind) LOCATION=\(.location)"')"
ibmcloud login --apikey=$API_KEY -a "cloud.ibm.com" -r $REGION -g $RESOURCE_GROUP
ibmcloud iam oauth-tokens
host_out=`ibmcloud sat host ls --location $LOCATION | grep $hostname`
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

ibmcloud sat host assign --cluster $LOCATION --location $LOCATION --host $HOST_ID --zone $zone

status='notready'
echo $status
while [ "$status" != "ready" ]
do
   if [[ $(ibmcloud sat host ls --location $LOCATION | grep $hostname) == *"Ready"* ]]; then
    echo host $hostname ready
    status="ready"
  fi
    echo *************hosts not ready*****************
    sleep 10
done



# echo -n "{\"assign_output\":\"${asout}\"}"
