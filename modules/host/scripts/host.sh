#!/bin/bash

# ibm cloud login
ibmcloud_login(){
    echo "************* ibmcloud cli login *****************"
    echo ENDPOINT= $ENDPOINT
    n=0
    until [ "$n" -ge 5 ]
    do
        ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP && break
        echo "************* Failed with $n, waiting to retry *****************"
        n=$((n+1))
        sleep 10
    done
    ibmcloud iam oauth-tokens
    sleep 10 
}

# login failure - retry method
login_error() {
    login_error=$(ibmcloud sat host ls --location $LOCATION 2>&1 | grep 'Log in to the IBM Cloud CLI by running')
    if [[ $login_error != "" ]]; then
        echo "Retry login again.."
        ibmcloud_login
    fi
}

# ibmcloud login call
ibmcloud_login

# Get proper hostname for AWS provider
if [ "$PROVIDER" == "aws" ]; then
    hostname=$(echo $hostname | cut -d "." -f 1)
fi

# Check host attached to location 
host_out=`ibmcloud sat host ls --location $LOCATION | grep $hostname`
rc=$?
while [ $rc -eq 1 ]
do
    #login failure - retry
    login_error
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
if [[  $(( $index % 3 )) == 0 ]]; then
    zone="$REGION-1"
elif [ $(( $index % 3 )) == 1 ]; then
    zone="$REGION-2"
elif [ $(( $index % 3 )) == 2 ]; then
    zone="$REGION-3"
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
   ibmcloud sat host assign --cluster $LOCATION --location $LOCATION --host $HOST_ID --zone $zone && break
   echo "************* Failed with $n, waiting to retry *****************"
   n=$((n+1))
   sleep 10
done

if [[ $? -ne 0 ]]; then
    echo "************* Failed to assign host $HOST_ID to zone $zone  *************"
    exit 1
fi

# Wait for host to get normal state
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


sleep 60
echo "Assiging host $hostname  to control plane completed.."
echo "Satellite control plane is setting up. Please wait for 40 mins to complete..!!!!"
exit 0
