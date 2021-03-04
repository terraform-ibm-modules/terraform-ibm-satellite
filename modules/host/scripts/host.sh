#!/bin/bash

# ibmcloud cli login
ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP
if [[ $? != 0 ]]; then
  exit 1
fi
sleep 10

# Check login status
login_status=$(ibmcloud sat host ls --location "$LOCATION" 2>&1 | grep 'Log in to the IBM Cloud CLI')
if [[ $login_status == *"Log in to the IBM Cloud CLI"* ]]; then
    echo "************* Login failure *****************"
    exit 1
fi
sleep 10

#Get location ID
loc_id=$(ibmcloud sat location ls 2>&1 | grep -w -m 1 "$LOCATION" | awk '{print $2}')
if [[ $loc_id != "" ]]; then
    LOCATION=$loc_id
    echo "*************  Using location ID '$LOCATION' for operations *************"
else 
    echo "************* Location '$LOCATION' not found. Exiting *****************"
    exit 1   
fi

# Get proper hostname for AWS provider
if [ "$PROVIDER" == "aws" ]; then
    hostname=$(echo $hostname | cut -d "." -f 1)
fi

# Check host attached to location 
status=0
echo LOCATION= $LOCATION
while [ $status -eq 0 ]
do
    host_out=`ibmcloud sat host ls --location "$LOCATION" | grep $hostname`
    HOST_ID=$(echo $host_out| cut -d' ' -f 2)
    if [[ $HOST_ID != "" ]]; then
        echo host $hostname attached
        status=1
        break
    fi
    echo "************* hosts not attached to location *****************"
    sleep 30
done

#Get host zone
host_zones=$(ibmcloud sat location get --location "$LOCATION" | grep 'Host Zones:' | awk '{print substr($0, index($0, $3))}')
echo host_zones= $host_zones
if [[ $host_zones != "" ]]; then
    export IFS=","
    i=0
    for z in $host_zones; do
        if [[  $(( $index % 3 )) == 0 && $i == 0 ]]; then
            zone=$(echo $z | tr -d ' ')
            break
        elif [[ $(( $index % 3 )) == 1  && $i == 1 ]]; then
            zone=$(echo $z | tr -d ' ')
            break
        elif [[ $(( $index % 3 )) == 2  && $i == 2 ]]; then
            zone=$(echo $z | tr -d ' ')
            break
        fi
        i=$((i+1))
    done
else
    echo "************* Location zones not found. Exiting *****************"
    exit 1
fi

# Assign host to location control plane
echo hostout= $host_out
echo hostid= $HOST_ID
echo zone= $zone
echo hostname= $hostname
echo location= $LOCATION
n=0
until [ "$n" -ge 5 ]
do
   ibmcloud sat host assign --cluster $LOCATION --location "$LOCATION" --host $HOST_ID --zone $zone && break
   echo "************* Failed with $n, waiting to retry *****************"
   n=$((n+1))
   sleep 10
done

if [[ $? -ne 0 ]]; then
    echo "************* Failed to assign host "$HOST_ID" to zone $zone  *************"
    exit 1
fi

# Wait for host to get normal state
status='notready'
echo $status
while [ "$status" != "ready" ]
do
   if [[ $(ibmcloud sat host ls --location "$LOCATION" | grep $hostname) == *"Ready"* ]]; then
    echo host $hostname ready
    status="ready"
    break
  fi
    echo "************* hosts not ready *****************"
    sleep 10
done

echo "Assiging host $hostname  to control plane completed.."
echo "Satellite control plane is setting up. Please wait for 40 mins to complete..!!!!"