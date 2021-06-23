#!/bin/bash

TF_LOG_TRUE_VAR=true
TF_LOG_FALSE_VAR=false

function debugIfNeeded() {
  case $DEBUG_SHELL in
    "$TF_LOG_TRUE_VAR") echo "** Shell debugging enabled **"; set -x; ;;
    "$TF_LOG_FALSE_VAR") echo "** Shell debugging disabled **"; ;;
    *) echo "** Shell debugging error ** - Unknown boolean value \"$DEBUG_SHELL\"" ;;
   esac
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