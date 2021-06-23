#!/bin/bash

TF_LOG_TRUE_VAR=true
TF_LOG_FALSE_VAR=false

function debugIfNeeded() {
  case $DEBUG_SHELL in
    "$TF_LOG_TRUE_VAR") echo "** Shell debugging enabled **"; set -x; ;;
    "$TF_LOG_FALSE_VAR") echo "** Shell debugging disabled **"; ;;
    *) echo "** Shell debugging error ** - Unknown boolean value \"$DEBUG_SHELL\"" ;;
   esac
}

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
  # out=$(ibmcloud sat location ls | grep -m 1 $LOCATION | cut -d' ' -f1)
  out=$(ibmcloud sat location ls | awk -v loc="$LOCATION" '$1==loc' | awk '{print $1}')
  if [[ $out != "" && $out == $LOCATION ]]; then
    return 0 # True
  else
    return 1 # False
  fi
}

function createLocationIfNeeded() {
  # Create new location or Use existing location ID
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

function main() {
  # Main
  ibmCloudLogin
  debugIfNeeded
  setZone  
  createLocationIfNeeded
}

# Execute
main
