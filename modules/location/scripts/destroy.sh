#!/bin/bash

echo ************* Deleting location *****************
echo LOCATION= $LOCATION
ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP
ibmcloud sat location rm --location $LOCATION -f
rm -rf /tmp/.schematics/addhost.sh