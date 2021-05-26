#!/bin/bash

function debugIfNeeded() {
  [[ $DEBUG_CLI == "true" ]] && set -x
}

echo ************* Deleting Hosts and location *****************

ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP
ibmcloud iam oauth-tokens

debugIfNeeded

if [ "$PROVIDER" == "aws" ]; then
    hostname=$(echo $hostname | cut -d "." -f 1)
fi

ibmcloud sat host rm --location $location --host $hostname -f
sleep 60