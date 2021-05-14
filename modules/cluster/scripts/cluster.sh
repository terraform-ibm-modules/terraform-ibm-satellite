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
  set +x 
  echo
  echo "********** ibmcloud cli login **********"
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

function getMandatedZones() {
  MANDATED_ZONES=(${host_zones//;/ })
}

function getDefaultZone() {
  getMandatedZones
  DEFAULT_ZONE=${MANDATED_ZONES[0]}
}

function createCluster() {
  getSatLocationID
  getDefaultZone
  retryCmd "ibmcloud ks cluster create satellite --enable-config-admin --name $cluster_name --location $location_id --zone ${DEFAULT_ZONE}"
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

function assignZoneToCluster() {
  local zone=$1
  echo
  echo "************* Assigning zone to cluster's default worker pool *************"
  echo
  echo "************* ibmcloud ks zone add satellite --worker-pool default --cluster ${cluster_name} --zone ${zone} *************"
  retryCmd "ibmcloud ks zone add satellite --worker-pool default --cluster ${cluster_name} --zone ${zone}"
  echo "$CMDOUT"
}

function assignZoneToClusterIfNeeded() {
  local zone=$1
  echo
  echo "********** Assign zone to cluster if needed **********"
  checkZoneExists $zone
  if [[ $? -eq 0 ]]; then
    echo
    echo "**********  Using existing ${zone} zone **********"
  else
    assignZoneToCluster $zone
    echo
    echo "********** Cluster ${zone} zone assigned **********"
  fi
}

function assignZonesToCluster() {
  getMandatedZones
  for i in "${MANDATED_ZONES[@]}"
  do
    assignZoneToClusterIfNeeded $i
  done
}

function apply() {
  ibmCloudLogin
  ensureLocationIsNormal
  createClusterIfNeeded
  assignZonesToCluster
}

apply
