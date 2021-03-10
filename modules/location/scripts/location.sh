#!/bin/bash

function ibmCloudLogin() {
  # ibmcloud cli login
  ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP
  if [[ $? != 0 ]]; then
    exit 1
  fi
}

ZONE=""
function setZone() {
  if [[ $REGION == "us-east" ]]; then
    ZONE="wdc06"
  elif [[ $REGION == "eu-gb" ]]; then
    ZONE="lon04"
  fi
}

function checkLocationNameExists() {
  echo Location="$LOCATION"
  out=$(ibmcloud sat location ls | grep -m 1 $LOCATION | cut -d' ' -f1)
  if [[ $out != "" && $out == $LOCATION ]]; then
    return 0 # True
  else
    return 1 # False
  fi
}

function createLocationIfNeeded() {
  #Create new location or Use existing location ID
  # Work around Satellite defect https://github.ibm.com/alchemy-containers/satellite-planning/issues/1331
  # out=$(ibmcloud sat location get --location $LOCATION 2>&1 | grep 'ID:')
  # if [[ $out != "" && $out != *"Incident"* ]]; then
  if checkLocationNameExists; then
    echo "*************  Using existing location ID for operations *************"
  else
    ibmcloud sat location create --managed-from $ZONE --name $LOCATION
    if [[ $? != 0 ]]; then
      exit 1
    fi
    sleep 60
  fi
}

LOCATION_ID=""
function getLocationID() {
  #Get satellite location ID
  local loc_id=$(ibmcloud sat location ls 2>&1 | grep -m 1 $LOCATION | awk '{print $2}')
  if [[ $loc_id != "" ]]; then
    LOCATION_ID=$loc_id
  else
    exit 1
  fi
}

function createTempScriptDirectoryIfNeeded() {
  #Create /tmp/.schematics directory
  script_dir="/tmp/.schematics"
  if [ ! -d "$script_dir" ]; then
    mkdir -p $script_dir
    if [[ $? != 0 ]]; then
      echo "*************  '$script_dir' directory creation failed. *************"
      exit 1
    fi
  fi
}

function generateHostAttachScript() {
  # Generate attach host script
  echo location=$LOCATION_ID
  n=0
  path_out=""
  until [ "$n" -ge 5 ]; do
    path_out=$(ibmcloud sat host attach --location $LOCATION_ID -hl $LABEL) && break
    echo "************* Failed with $n, waiting to retry *****************"
    n=$((n + 1))
    sleep 10
  done

  echo $path_out
  path=$(echo $path_out | cut -d' ' -f 21)
  echo path= $path
  if [[ $path == "" ]]; then
    echo "************* Failed to generate registration script *****************"
    exit 1
  fi

  #Update host registration script
  if [[ $PROVIDER == "ibm" ]]; then
    awk '1;/API_URL=/{ print "subscription-manager refresh"; print "subscription-manager repos --enable=*";}' $path >$ADDHOST_PATH/addhost.sh
  elif [[ $PROVIDER == "aws" ]]; then
    awk '1;/API_URL=/{ print "yum update -y"; print "yum-config-manager --enable \x27*\x27"; print "yum repolist all"; print "yum install container-selinux -y";}' $path >$ADDHOST_PATH/addhost.sh
  fi
}

function main() {
  #Main
  # createTempScriptDirectoryIfNeeded
  setZone
  ibmCloudLogin
  createLocationIfNeeded
  getLocationID
  generateHostAttachScript
}

# Execute
main
