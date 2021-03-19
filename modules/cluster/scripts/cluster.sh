#!/bin/bash -x 

MAX_RETRY=10

function snooze() {
  sleep 30
}

function retryCmd() {
  local cmd=$*
  local n=1
  until [ "$n" -ge $MAX_RETRY ]; do
    echo ">>>>>>>>>> ATTEMPT $n"
    CMDOUT=$(${cmd}) && break
    echo $CMDOUT
    n=$((n + 1))
    if [ "$n" -ge $MAX_RETRY ]; then
      echo ">>>>>>>>>> FAILED"
      exit 1
    fi
    sleep 1
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

function getSatLocationID() {
  retryCmd "ibmcloud sat location get --location ${LOCATION}"
  location_id=$(echo "$CMDOUT" | awk '/ID:/{print $2;exit;}')
  echo "location id = $location_id"
}

function getLocationState() {
  retryCmd "ibmcloud sat location get --location ${LOCATION}"
  LOCATION_STATE=$(echo "$CMDOUT" | awk '/State/{print $2;exit;}')
  echo "location $LOCATION status: $LOCATION_STATE"
}

function ensureLocationIsNormal() {
  getLocationState
  while [[ $LOCATION_STATE != "normal" ]]; do
    echo "********** Location NOT ready **********"
    snooze
    getLocationState
  done
  echo "********** Location ready **********"
}

function clusterNameExists() {
  retryCmd "ibmcloud ks cluster ls"
  out=$(echo "$CMDOUT" | grep -m 1 "$cluster_name" | awk '{print $1}')
  if [[ $out != "" && $out == $cluster_name ]]; then
    return 0 # True
  else
    return 1 # False
  fi
}

function getClusterState() {
  retryCmd "ibmcloud ks cluster get --cluster ${cluster_name}"
  CLUSTER_STATE=$(echo "$CMDOUT" | awk '/State/{print $2;exit;}')
  echo "cluster $cluster_name status: $CLUSTER_STATE"
}

function createCluster() {
  getSatLocationID
  retryCmd "ibmcloud ks cluster create satellite --enable-config-admin --name $cluster_name --location $location_id --version 4.5.31_openshift"
}

function validateClusterCreation() {
  getClusterState
  while [ $CLUSTER_STATE != "warning" ]; do
    echo "********** cluster not ready **********"
    snooze
    getClusterState
  done
  echo "Satellite UX shows Active when the cluster is in warning so we assume creation completed"
  echo "********** cluster creation done **********"
}

function createClusterIfNeeded() {
  if clusterNameExists; then
    echo "**********  Using existing cluster for operations **********"
    exit 0
  else
    createCluster
    validateClusterCreation
  fi
}

function apply() {
  ibmCloudLogin
  ensureLocationIsNormal
  createClusterIfNeeded
}

apply
