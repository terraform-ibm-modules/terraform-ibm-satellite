#!/bin/bash


echo "************* ibmcloud cli login *****************"
ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP
ibmcloud iam oauth-tokens
if [[ $? -ne 0 ]]; then
  n=0
  until [ "$n" -ge 5 ]
  do
    ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP  && break
    echo "************* Failed with $n, waiting to retry *****************"
    n=$((n+1))
    sleep 30
  done
fi

ibmcloud iam oauth-tokens

status="action_required"
while [ "$status" != "normal" ]
do
    echo "************* Location not ready *****************"
    sleep 30
   if [[ $(ibmcloud sat location get --location $LOCATION | grep State:) == *"normal"* ]]; then
    echo location $LOCATION is normal
    status="normal"
    break
  fi
done

out=$(ibmcloud sat location get --location $LOCATION | grep ID)
location_id=$(echo $out| cut -d' ' -f 2)
echo "location id = $location_id"

ibmcloud ks cluster create satellite --name $cluster_name --location $location_id --version 4.4_openshift
state="deploying"
while [ "$status" != "warning" ]
do
    echo "************* cluster not ready *****************"
    sleep 30
   if [[ $(ibmcloud ks cluster get --cluster $cluster_name | grep State:) == *"warning"* ]]; then
    echo location $cluster_name is warning
    status="warning"
    break
  fi
done

echo "**************** cluster creation done ****************"
