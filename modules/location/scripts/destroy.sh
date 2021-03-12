#!/bin/bash

echo ************* Deleting location *****************
echo LOCATION= $LOCATION
ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP

#Get location ID
loc_id=$(ibmcloud sat location ls 2>&1 | grep -m 1 $LOCATION | awk '{print $2}')
if [[ $loc_id != "" ]]; then
    LOCATION=$loc_id
else
    echo "************* Location '$LOCATION' not found. Exiting *****************"
    exit 1
fi

# While hosts remain in the location
while [ $(ibmcloud sat host ls --location $LOCATION | wc -l) -ge 4 ]; do
    echo "************* Location '$LOCATION' still has control plain hosts attached. Trying again in 10 seconds *****************"
    sleep 10
done

# Remove satellite location
n=0
until [ "$n" -ge 5 ]; do
    ibmcloud sat location rm --location $LOCATION -f && break
    echo "************* Failed with $n, waiting to retry *****************"
    n=$((n + 1))
    sleep 10
done
sleep 120

# Wait for location to get deleted
status=0
echo LOCATION= $LOCATION
while [ $status -eq 0 ]; do
    loc_out=$(ibmcloud sat location get --location $LOCATION 2>&1 | grep State: | awk '{print $2}')
    echo loc_out= $loc_out
    if [[ $loc_out != "deleting" && $loc_out != "deploying" && $loc_out != "action required" ]]; then
        echo Location $LOCATION deleted
        status=1
        break
    fi
    echo "************* Location is getting deleted *****************"
    sleep 30
done
