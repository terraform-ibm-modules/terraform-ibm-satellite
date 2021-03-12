#!/bin/bash

function snooze() {
  sleep 10
}

function ibmCloudLogin() {
  echo "************* ibmcloud cli login *****************"
  n=0
  max=5
  until [ "$n" -ge $max ]; do
    ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP && break
    echo "************* Failed with $n, waiting to retry *****************"
    n=$((n + 1))
    snooze
    if [ "$n" -ge $max ]; then
      echo "************* Failed to login *****************"
      exit 1
    fi
  done
}

function extractHostName() {
  if [ "$PROVIDER" == "aws" ]; then
    HOSTNAME=$(echo $hostname | cut -d "." -f 1)
  fi
}

function lsSatelliteHost() {
  echo "************* ibmcloud sat host ls --location "$location" *****************"
  n=0
  max=5
  until [ "$n" -ge $max ]; do
    LSOUT=$(ibmcloud sat host ls --location "$location") && break
    echo "************* Failed with $n, waiting to retry *****************"
    n=$((n + 1))
    snooze
    if [ "$n" -ge $max ]; then
      echo "************* Failed to list hosts *****************"
      exit 1
    fi
  done
}

function getHostID() {
  lsSatelliteHost
  extractHostName
  HOST_ID=$(echo "$LSOUT" | grep $HOSTNAME | awk '{print $2}')
}

function checkHostExists() {
  tries=0
  getHostID
  while [ "$HOST_ID" == "" ]; do
    echo "************* Sleeping until ${hostname} exists ************* "
    snooze
    getHostID
  done
}

function debugValues() {
  echo location= $location
  echo cluster= $cluster_name
  echo provider= $PROVIDER
  echo hostname= $hostname
  echo HOSTNAME= $HOSTNAME
  echo HOST_ID= $HOST_ID
  echo zone= $zone
}

# Assign host to openshift cluster
function assignHostToCluster() {
  echo "************* ibmcloud sat host assign --cluster "$cluster_name" --location "$location" --host "$HOST_ID" --zone "$zone" *****************"
  n=0
  max=5
  until [ "$n" -ge $max ]; do
    # Hack around Satellite https://github.ibm.com/alchemy-containers/satellite-planning/issues/1343
    ibmcloud sat host assign --cluster "$cluster_name" --location "$location" --host "$HOST_ID" && break
    #ibmcloud sat host assign --cluster "$cluster_name" --location "$location" --host "$HOST_ID" --zone "$zone" && break
    echo "************* Failed with $n, waiting to retry *****************"
    n=$((n + 1))
    snooze
    if [ "$n" -ge $max ]; then
      echo "************* Failed to assign cluster *****************"
      exit 1
    fi
  done
}

function validateHostAssignment() {
  lsSatelliteHost
  while [ $(echo "$LSOUT" | grep "$HOSTNAME" | awk '{print $3}') == "unassigned" ]; do
    echo "************* hosts NOT assigned *****************"
    snooze
    lsSatelliteHost
  done
  echo "************* Assigning host $hostname to cluster completed.. *************"
}

function main() {
  ibmCloudLogin
  checkHostExists
  debugValues
  assignHostToCluster
  validateHostAssignment
}

main
