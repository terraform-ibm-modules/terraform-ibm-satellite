#!/bin/bash -x
set -e

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

function getSatLocation() {
  status="action_required"
  while [ "$status" != "normal" ]; do
    if [[ $(ibmcloud sat location get --location $LOCATION | grep State:) == *"normal"* ]]; then
      echo location $LOCATION is normal
      status="normal"
      break
    fi
    echo "************* Location not ready *****************"
    sleep 30
  done
  out=$(ibmcloud sat location get --location $LOCATION | grep ID)
  location_id=$(echo $out | cut -d' ' -f 2)
  echo "location id = $location_id"
}

function checkClusterNameExists() {
  out=$(ibmcloud ks cluster ls | grep -m 1 $cluster_name | cut -d' ' -f1)
  if [[ $out != "" && $out == $cluster_name ]]; then
    return 0 # True
  else
    return 1 # False
  fi
}

function createClusterIfNeeded() {
  if checkClusterNameExists; then
    echo "*************  Using existing cluster ID for operations *************"
    return 0
  else
    ibmcloud ks cluster create satellite --name $cluster_name --location $location_id --version 4.5.31_openshift
    while [ $(ibmcloud ks cluster get --cluster $cluster_name | grep State:) != *"warning"* ]; do
      echo "************* cluster not ready *****************"
      sleep 30
    done
    echo location $cluster_name is warning
    echo "**************** cluster creation done ****************"
  fi
}

function main() {
  #Main
  ibmCloudLogin
  getSatLocation
  createClusterIfNeeded
}

main
