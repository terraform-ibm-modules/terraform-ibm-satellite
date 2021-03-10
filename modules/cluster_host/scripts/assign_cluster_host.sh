#!/bin/bash -x

function ibmCloudLogin() {
  echo "************* ibmcloud cli login *****************"
  n=0
  until [ "$n" -ge 5 ]; do
    ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP && break
    echo "************* Failed with $n, waiting to retry *****************"
    n=$((n + 1))
    sleep 30
    if [ "$n" -ge 5 ]; then
      echo "************* Failed to login *****************"
      exit 1
    fi
  done
}

function checkHostExists() {
  if [ "$PROVIDER" == "aws" ]; then
    hostname=$(echo $hostname | cut -d "." -f 1)
  fi

  tries=0
  host_out=$(ibmcloud sat host ls --location "$location" | grep $hostname)
  status_code=$?
  while [ "$status_code" -ne 0 ]; do
    echo "************* Sleeping until ${hostname} exists ************* "
    sleep 10
    host_out=$(ibmcloud sat host ls --location "$location" | grep $hostname)
    status_code=$?
  done
  HOST_ID=$(echo $host_out | cut -d' ' -f 2)
}

function debugValues() {
  echo hostout= $host_out
  echo hostid= $HOST_ID
  echo hostname= $hostname
  echo location= $location
  echo cluster= $cluster_name
  echo provider= $PROVIDER
}

# Assign host to openshift cluster
function assignHostToCluster() {
  n=0
  until [ "$n" -ge 5 ]; do
    ibmcloud sat host assign --cluster $cluster_name --location $location --host $HOST_ID --zone $zone && break
    echo "************* Failed with $n, waiting to retry *****************"
    n=$((n + 1))
    sleep 10
  done

  while [ $(ibmcloud sat host ls --location $location | grep $hostname) != "Ready" ]; do
    echo "************* hosts Not ready *****************"
    sleep 10
  done
  echo host $hostname Ready

  echo "************* Adding host to cluster completed.. *************"
}

function main() {
  #Main
  ibmCloudLogin
  checkHostExists
  debugValues
  assignHostToCluster
}

main
