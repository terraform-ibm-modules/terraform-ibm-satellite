#!/bin/bash

# ibmcloud cli login
ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP
if [[ $? != 0 ]]; then
  exit 1
fi

ZONE=""
if [[ $REGION == "us-east" ]]; then
  ZONE="wdc06"
elif [[ $REGION == "eu-gb" ]]; then
  ZONE="lon04"  
fi

#Check location name exist
echo Location= $LOCATION
out=$(ibmcloud sat location ls | grep -m 1 $LOCATION |  cut -d' ' -f1)
if [[ $out != "" && $out == $LOCATION ]]; then
 echo "************* satellite location already exist *****************"
 exit 1
fi

#Create new location or Use existing location ID
out=$(ibmcloud sat location get --location $LOCATION 2>&1 | grep 'ID:')
if [[ $out != "" && $out != *"Incident"* ]]; then
  echo "*************  Using location ID for operations *************"
else
  ibmcloud sat location create --managed-from $ZONE --name $LOCATION
  if [[ $? != 0 ]]; then
    exit 1
  fi
  sleep 200
  #Get satellite location ID
  loc_id=$(ibmcloud sat location ls 2>&1 | grep -m 1 $LOCATION | awk '{print $2}')
  if [[ $loc_id != "" ]]; then
    LOCATION=$loc_id
  fi
fi

# Generate attach host script
echo location= $LOCATION
n=0
path_out=""
until [ "$n" -ge 5 ]
do
   path_out=`ibmcloud sat host attach --location $LOCATION -hl $LABEL` && break
   echo "************* Failed with $n, waiting to retry *****************"
   n=$((n+1))
   sleep 10
done

echo $path_out
path=$(echo $path_out| cut -d' ' -f 21)
echo path= $path
if [[ $path == "" ]]; then
  echo "************* Failed to generate registration script *****************"
  exit 1
fi

#Update host registration script 
if [[ $PROVIDER == "ibm" ]];
then
  awk '1;/API_URL=/{ print "subscription-manager refresh"; print "subscription-manager repos --enable=*";}' $path  > /tmp/.schematics/addhost.sh
elif [[ $PROVIDER == "aws" ]];
then
  awk '1;/API_URL=/{ print "yum update -y"; print "yum-config-manager --enable \x27*\x27"; print "yum repolist all"; print "yum install container-selinux -y";}' $path  > /tmp/.schematics/addhost.sh
fi
