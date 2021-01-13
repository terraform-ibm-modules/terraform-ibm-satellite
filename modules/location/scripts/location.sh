
#!/bin/bash

echo *************create location*****************
ibmcloud login --apikey=$API_KEY -a $ENDPOINT -r $REGION -g $RESOURCE_GROUP
ibmcloud iam oauth-tokens
ibmcloud sat location create --managed-from $ZONE --name $LOCATION
status='provisioning'
echo $status
while [ "$status" != "action" ]
do
   if [[ $(ibmcloud sat location get --location $LOCATION | grep State:) == *"action required"* ]]; then
    echo status = action required
    status="action"
  fi
   echo "************* provisioning location *****************"
   sleep 10
done

path_out=`ibmcloud sat host attach --location $LOCATION -l $LABEL`
echo $path_out
if [[ $path_out == "" ]]; then
  echo "************* Failed to generate script *************"
  exit 1
fi


path=$(echo $path_out| cut -d' ' -f 21)
echo path= $path
if [[ $PROVIDER == "ibm" ]];
then
  awk '1;/API_URL=/{ print "subscription-manager refresh"; print "subscription-manager repos --enable=*";}' $path  > addhost.sh
elif [[ $PROVIDER == "aws" ]];
then
  awk '1;/API_URL=/{ print "yum update -y"; print "yum-config-manager --enable \x27*\x27"; print "yum repolist all"; print "yum install container-selinux -y";}' $path  > addhost.sh
fi
