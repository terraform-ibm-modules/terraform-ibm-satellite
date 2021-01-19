#!/bin/bash

echo ************* Deleting Hosts *****************
ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP
ibmcloud iam oauth-tokens
ibmcloud sat host rm --location $LOCATION --host $hostname