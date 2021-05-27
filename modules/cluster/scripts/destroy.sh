#!/bin/bash 

TF_LOG_TRUE_VAR=true
TF_LOG_FALSE_VAR=false

function debugIfNeeded() {
  case $DEBUG_SHELL in
    "$TF_LOG_TRUE_VAR") echo "** Shell debugging enabled **"; set -x; ;;
    "$TF_LOG_FALSE_VAR") echo "**S hell debugging disabled **"; ;;
    *) echo "** Shell debugging error ** - Unknown boolean value \"$DEBUG_SHELL\"" ;;
   esac
}

echo ************* Deleting Hosts and location *****************
ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP
ibmcloud iam oauth-tokens

debugIfNeeded

ibmcloud ks cluster rm --cluster $cluster_name -f
sleep 30

ibmcloud ks cluster ls | grep $cluster_name
while [ $? -eq 0 ]
do
    cluster_out=`ibmcloud ks cluster ls | grep $cluster_name`
    if [[ $cluster_out == "" ]]; then
        echo Cluster $cluster_name removed.
        break
    fi
    echo "************* Cluster is getting delete *****************"
    sleep 10
done   