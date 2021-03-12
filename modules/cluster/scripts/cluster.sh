#!/bin/bash -e

function exitOnFail() {
  exitStatus=$?
  if [ ! $exitStatus -eq 0 ]; then
    echo "Exit status: " $exitStatus
    exit $exitStatus
  fi
}

function snooze() {
  sleep 30
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

function getSatLocation() {
  out=$(ibmcloud sat location get --location "$LOCATION" | grep ID)
  location_id=$(echo $out | cut -d' ' -f 2)
  echo "location id = $location_id"
}

function getLocationState() {
  LOCATION_STATE=$(ibmcloud sat location get --location "$LOCATION" | awk '/State/{print $2;exit;}')
  echo "location $LOCATION status: $LOCATION_STATE"
}

function ensureLocationIsNormal() {
  getLocationState
  while [[ $LOCATION_STATE != "normal" ]]; do
    echo "************* Location NOT ready *****************"
    snooze
    getLocationState
  done
  echo "************* Location ready *****************"
}

function checkClusterNameExists() {
  out=$(ibmcloud ks cluster ls | grep -m 1 "$cluster_name" | cut -d' ' -f1)
  if [[ $out != "" && $out == $cluster_name ]]; then
    return 0 # True
  else
    return 1 # False
  fi
}

function getClusterState() {
  CLUSTER_STATE=$(ibmcloud ks cluster get --cluster "$cluster_name" | awk '/State/{print $2;exit;}')
  echo "cluster $cluster_name status: $CLUSTER_STATE"
}

function validateClusterCreation() {
  getClusterState
  while [ $CLUSTER_STATE != "warning" ]; do
    echo "************* cluster not ready *****************"
    snooze
    getClusterState
  done
  echo "Satellite UX shows Active when the cluster is in warning so we assume creation completed"
  echo "**************** cluster creation done ****************"
}

function createClusterIfNeeded() {
  if checkClusterNameExists; then
    echo "*************  Using existing cluster ID for operations *************"
    exit 0
  else
    ibmcloud ks cluster create satellite --enable-config-admin --name $cluster_name --location $location_id --version 4.5.31_openshift
    exitOnFail
    validateClusterCreation
  fi
}

function main() {
  ibmCloudLogin
  getSatLocation
  ensureLocationIsNormal
  createClusterIfNeeded
}

main
