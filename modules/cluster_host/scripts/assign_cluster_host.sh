
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
    sleep 10
  done
fi
ibmcloud iam oauth-tokens


if [ "$PROVIDER" == "aws" ]; then
    hostname=$(echo $hostname | cut -d "." -f 1)
fi

tries=0
status_code=1
host_out=$(ibmcloud sat host ls --location "$location"| grep $hostname)
while [ "$status_code" -ne 0 ]
do
  host_out=$(ibmcloud sat host ls --location "$location"| grep $hostname)
  status_code=$?
  echo "************* Sleeping until ${hostname} exists ************* "
  sleep 10
done

HOST_ID=$(echo $host_out| cut -d' ' -f 2)

echo hostout= $host_out
echo hostid= $HOST_ID
echo hostname= $hostname
echo location= $location
echo cluster= $cluster_name
echo provider= $PROVIDER

# Assign host to openshift cluster
n=0
until [ "$n" -ge 5 ]
do
  ibmcloud sat host assign --cluster $cluster_name --location $location --host $HOST_ID --zone $zone && break
  echo "************* Failed with $n, waiting to retry *****************"
  n=$((n+1))
  sleep 10
done

status='Not Ready'
echo $status
while [ "$status" != "Ready" ]
do
   if [[ $(ibmcloud sat host ls --location $location | grep $hostname) == *"Ready"* ]]; then
    echo host $hostname Ready
    status="Ready"
    break
  fi
    echo "************* hosts Not ready *****************"
    sleep 10
done

echo "************* Adding host to cluster completed.. *************"
