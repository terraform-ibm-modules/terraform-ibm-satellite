#!/bin/bash

MAX_RETRY=5

function snooze() {
  sleep 10
}

function ibmCloudLogin() {
  echo "************* ibmcloud cli login *****************"
  n=0
  until [ "$n" -ge $MAX_RETRY ]; do
    ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP && break
    echo "************* Failed with $n, waiting to retry *****************"
    n=$((n + 1))
    snooze
    if [ "$n" -ge $MAX_RETRY ]; then
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

function lsSatelliteHosts() {
  echo "************* ibmcloud sat host ls --location ${location} *****************"
  n=0
  until [ "$n" -ge $MAX_RETRY ]; do
    LSOUT=$(ibmcloud sat host ls --location "$location") && break
    echo "************* Failed with $n, waiting to retry *****************"
    n=$((n + 1))
    snooze
    if [ "$n" -ge $MAX_RETRY ]; then
      echo "************* Failed to list hosts *****************"
      exit 1
    fi
  done
}

function getHostID() {
  lsSatelliteHosts
  echo "$LSOUT"
  extractHostName
  HOST_ID=$(echo "$LSOUT" | grep "$HOSTNAME" | awk '{print $2}')
}

function checkHostExists() {
  echo "************* Checking host ${hostname} exists *****************"
  getHostID
  while [[ "$HOST_ID" == "" ]]; do
    echo "************* Sleeping until ${hostname}(${HOST_ID}) exists *************"
    snooze
    getHostID
  done
  echo "************* Host ${hostname}(${HOST_ID}) found *************"
}

function debugValues() {
  echo "************* Input Values *************"
  echo location= $location
  echo cluster= $cluster_name
  echo provider= $PROVIDER
  echo hostname= $hostname
  echo HOSTNAME= $HOSTNAME
  echo HOST_ID= $HOST_ID
  echo zone= $zone
}

# Get all cluster zones in default worker pool
function getClusterZones() {
  echo "************* Getting cluster default worker pool zones *****************"
  echo "************* ibmcloud ks worker-pool get --worker-pool default --cluster ${cluster_name} *****************"
  n=0
  until [ "$n" -ge $MAX_RETRY ]; do
    CLUSTER_ZONES=$(ibmcloud ks worker-pool get --worker-pool default --cluster "$cluster_name") && break;
    echo "************* Failed with $n, waiting to retry *****************"
    n=$((n + 1))
    snooze
    if [ "$n" -ge $MAX_RETRY ]; then
      echo "************* Failed to get cluster zones *****************"
      exit 1
    fi
  done
}

# Check if the zone already exists in default worker pool
function checkZoneExists() {
  getClusterZones
  echo "$CLUSTER_ZONES"
  zoneout=$(echo "$CLUSTER_ZONES" | grep "$zone" | awk '{print $1}')
  if [[ $zoneout != "" && $zoneout == $zone ]]; then
    return 0 # True
  else
    return 1 # False
  fi
}

# Assign zone to cluster's default worker pool
function assignZoneToCluster() {
  echo "************* Assigning zone to cluster's default worker pool *****************"
  echo "************* ibmcloud ks zone add satellite --worker-pool default --cluster ${cluster_name} --zone ${zone} *****************"
  n=0
  until [ "$n" -ge $MAX_RETRY ]; do
    ibmcloud ks zone add satellite --worker-pool default --cluster "$cluster_name" --zone "$zone" && break;
    echo "************* Failed with $n, waiting to retry *****************"
    n=$((n + 1))
    snooze
    if [ "$n" -ge $MAX_RETRY ]; then
      echo "************* Failed to assign cluster zone *****************"
      exit 1
    fi
  done
}

# Assign zone to cluster only if it doesn't already exist
function assignZoneToClusterIfNeeded() {
  echo "************* Assign zone to cluster if needed *****************"
  if checkZoneExists; then
    echo "*************  Using existing ${zone} zone *************"
  else
    assignZoneToCluster
    echo "*************  Cluster ${zone} zone assigned *************"
  fi
}

# Assign host to openshift cluster
function assignHostToCluster() {
  echo "************* Assign host to cluster *****************"
  echo "************* ibmcloud sat host assign --cluster ${cluster_name} --location ${location} --host ${HOST_ID} --zone ${zone} *****************"
  n=0
  until [ "$n" -ge $MAX_RETRY ]; do
    ibmcloud sat host assign --cluster "$cluster_name" --location "$location" --host "$HOST_ID" --zone "$zone" && break
    echo "************* Failed with $n, waiting to retry *****************"
    n=$((n + 1))
    snooze
    if [ "$n" -ge $MAX_RETRY ]; then
      echo "************* Failed to assign host ${HOST_ID} to cluster ${cluster_name} *****************"
      exit 1
    fi
  done
}

function validateHostAssignment() {
  echo "************* Host assignment validation *****************"
  lsSatelliteHosts
  while [ $(echo "$LSOUT" | grep "$HOSTNAME" | awk '{print $3}') == "unassigned" ]; do
    echo "************* Host ${HOSTNAME} unassigned *****************"
    snooze
    lsSatelliteHosts
  done
  echo "************* Host ${hostname} assignment to cluster ${cluster_name} completed *************"
}

function main() {
  ibmCloudLogin
  checkHostExists
  # debugValues
  assignZoneToClusterIfNeeded
  assignHostToCluster
  validateHostAssignment
}

main
