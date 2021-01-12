#!/bin/bash

echo ************* Deleting Hosts and location *****************
ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP
ibmcloud iam oauth-tokens
ibmcloud sat location rm --location $LOCATION -f
