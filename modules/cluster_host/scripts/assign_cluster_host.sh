#!/bin/bash -x

function snooze() {
  sleep 30
}

function retryCmd() {
  local cmd=$*
  local n=1
  local MAX_RETRY=10
  until [ "$n" -ge $MAX_RETRY ]; do
    echo ">>>>>>>>>> ATTEMPT $n"
    CMDOUT=$(${cmd}) && break
    echo $CMDOUT
    n=$((n + 1))
    if [ "$n" -ge $MAX_RETRY ]; then
      echo ">>>>>>>>>> FAILED"
      exit 1
    fi
    snooze
  done
}

function ibmCloudLogin() {
  echo
  echo "********** ibmcloud cli login **********"
  set +x
  retryCmd "ibmcloud login --apikey=${API_KEY} -a ${ENDPOINT} -r ${REGION} -g ${RESOURCE_GROUP}"
  set -x
  echo "$CMDOUT"
}

function extractHostName() {
  HOSTNAME=$hostname
  if [ "$PROVIDER" == "aws" ]; then
    HOSTNAME=$(echo $hostname | cut -d "." -f 1)
  fi
}

function lsSatelliteHosts() {
  echo
  echo "********** ibmcloud sat host ls --location ${location} **********"
  retryCmd "ibmcloud sat host ls --location ${location}"
}

function getHostID() {
  extractHostName
  lsSatelliteHosts
  echo "$CMDOUT"
  HOST_ID=$(echo "$CMDOUT" | grep "$HOSTNAME" | awk '{print $2}')
}

function debugValues() {
  extractHostName
  echo "********** Input Values **********"
  echo location= $location
  echo cluster= $cluster_name
  echo provider= $PROVIDER
  echo hostname= $hostname
  echo HOSTNAME= $HOSTNAME
  echo HOST_ID= $HOST_ID
  echo zone= $zone
}

function checkHostExists() {
  echo
  echo "********** Checking host ${hostname} exists **********"
  getHostID
  while [[ "$HOST_ID" == "" ]]; do
    echo "********** Sleeping until Host ${hostname} / ID ${HOST_ID}) exists **********"
    snooze
    getHostID
  done
  echo
  echo "********** Host ${hostname} / ID ${HOST_ID} found **********"
}

# Get all cluster zones in default worker pool
function getClusterZones() {
  echo
  echo "********** Getting cluster default worker pool zones **********"
  echo
  echo "********** ibmcloud ks worker-pool zones --worker-pool default --cluster ${cluster_name} **********"
  echo
  retryCmd "ibmcloud ks worker-pool zones --worker-pool default --cluster ${cluster_name}"
  echo
  echo "$CMDOUT"
}

# Check if the zone already exists in default worker pool
function checkZoneExists() {
  local testZone=$1
  echo
  echo "Looking for zone $testZone"
  getClusterZones
  # Produce empty string when there are no zones assigned
  # (I'm not happy with this hack but we are running out of time so it will have to be that way for now)
  local data=$(echo "$CMDOUT" | grep -v "Retrieving" | grep -v "OK" | grep -v "Subnet")
  # Input is either empty or contains one or more zones
  zoneout=$(echo "$data" | grep -m 1 "$testZone" | awk '{print $1}')
  # Output is either empty or contains only one zone
  if [[ $zoneout != "" && $zoneout == $testZone ]]; then
    echo ">>>>>>>>>> Zone $testZone found"
    return 0 # True
  else
    echo ">>>>>>>>>> Zone $testZone NOT found"
    return 1 # False
  fi
}

function removeDefaultZone() {
  local defaultZone="zone-1"
  echo
  echo "************* Remove ${defaultZone} from cluster's default worker pool *************"
  echo
  echo "************* ibmcloud ks zone rm -f --worker-pool default --cluster ${cluster_name} --zone ${defaultZone} *************"
  retryCmd "ibmcloud ks zone rm -f --worker-pool default --cluster ${cluster_name} --zone ${defaultZone}"
  echo "$CMDOUT"
}

function removeDefaultZoneIfNeeded() {
  echo
  echo "********** Remove default zone-1 if needed **********"
  checkZoneExists "zone-1"
  if [[ $? -eq 0 ]]; then
    echo
    echo "********** Removing default zone-1 **********"
    removeDefaultZone
  else
    echo "********** Default zone-1 not found **********"
  fi
}

# Assign zone to cluster's default worker pool
function assignZoneToCluster() {
  echo
  echo "************* Assigning zone to cluster's default worker pool *************"
  echo
  echo "************* ibmcloud ks zone add satellite --worker-pool default --cluster ${cluster_name} --zone ${zone} *************"
  retryCmd "ibmcloud ks zone add satellite --worker-pool default --cluster ${cluster_name} --zone ${zone}"
  echo "$CMDOUT"
}

# Assign zone to cluster only if it doesn't already exist
function assignZoneToClusterIfNeeded() {
  echo
  echo "********** Assign zone to cluster if needed **********"
  checkZoneExists $zone
  if [[ $? -eq 0 ]]; then
    echo
    echo "**********  Using existing ${zone} zone **********"
  else
    assignZoneToCluster
    echo
    echo "********** Cluster ${zone} zone assigned **********"
  fi
}

function checkHostIsAlreadyAssigned() {
  lsSatelliteHosts
  if [[ $(echo "$CMDOUT" | grep "$HOSTNAME" | awk '{print $3}') == "assigned" ]]; then
    return 0 # True
  else
    return 1 # False
  fi
}

# Assign host to openshift cluster
function assignHostToCluster() {
  echo
  echo "********** Assign host to cluster **********"
  echo
  echo "********** ibmcloud sat host assign --cluster ${cluster_name} --location ${location} --host ${HOST_ID} --zone ${zone} **********"
  retryCmd "ibmcloud sat host assign --cluster ${cluster_name} --location ${location} --host ${HOST_ID} --zone ${zone}"
  echo "$CMDOUT"
}

function validateHostAssignment() {
  echo
  echo "********** Host assignment validation **********"
  lsSatelliteHosts
  while [ $(echo "$CMDOUT" | grep "$HOSTNAME" | awk '{print $3}') == "unassigned" ]; do
    echo "********** Host ${HOSTNAME} unassigned **********"
    snooze
    lsSatelliteHosts
  done
  echo "********** Host ${HOSTNAME} assignment to cluster ${cluster_name} completed **********"
}

# Assign host to cluster only if it's not already assigned
function assignHostToClusterIfNeeded() {
  echo
  echo "********** Assign host to cluster if needed **********"
  if checkHostIsAlreadyAssigned; then
    echo
    echo "********** Using existing ${hostname} assignment **********"
  else
    assignHostToCluster
    validateHostAssignment
  fi
}

function apply() {
  ibmCloudLogin
  debugValues
  checkHostExists
  removeDefaultZoneIfNeeded
  assignZoneToClusterIfNeeded
  assignHostToClusterIfNeeded
}

apply
