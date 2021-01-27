
#!/bin/bash

echo "************* ibmcloud cli login *****************"
ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP

ZONE=""
if [[ $REGION == "us-east" ]]; then
  ZONE="wdc06"
elif [[ $REGION == "eu-gb" ]]; then
  ZONE="lon04"  
fi


echo "************* create satellite location *****************"
ibmcloud sat location create --managed-from $ZONE --name $LOCATION

sleep 30
status='provisioning'
echo $status
while [ "$status" != "action" ]
do
   if [[ $(ibmcloud sat location get --location $LOCATION | grep State:) == *"action required"* ]]; then
    echo status = action required
    status="action"
  fi
   echo "************* provisioning location $LOCATION  *****************"
   sleep 60
done

echo location= $LOCATION
n=0
path_out=""
until [ "$n" -ge 5 ]
do
   path_out=`ibmcloud sat host attach --location $LOCATION -l $LABEL` && break
   echo "************* Failed with $n, waiting to retry *****************"
   n=$((n+1))
   sleep 10
done

echo $path_out
path=$(echo $path_out| cut -d' ' -f 21)
echo path= $path
if [[ $PROVIDER == "ibm" ]];
then
  awk '1;/API_URL=/{ print "subscription-manager refresh"; print "subscription-manager repos --enable=*";}' $path  > addhost.sh
elif [[ $PROVIDER == "aws" ]];
then
  awk '1;/API_URL=/{ print "yum update -y"; print "yum-config-manager --enable \x27*\x27"; print "yum repolist all"; print "yum install container-selinux -y";}' $path  > addhost.sh
fi
