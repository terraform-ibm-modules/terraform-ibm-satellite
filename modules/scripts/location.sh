
#!/bin/bash

# LOCATION="testloc7m"
# ZONE="dal10"
# COS_KEY="ce80781bec96a472e5b2102ad138edcc389e7fd9eadd236"
# COS_KEY_ID="d28e72294ded4ac093912d4a6ef8af53"
# LABEL="aa=aa"
echo *************create location*****************
ibmcloud login --apikey=$API_KEY -a "cloud.ibm.com" -r $REGION -g $RESOURCE_GROUP
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
   echo *************provisioning location*****************
    sleep 10
done

path_out=`ibmcloud sat host attach --location $LOCATION -l $LABEL`
echo $path_out
path=$(echo $path_out| cut -d' ' -f 21)
echo path= $path
if [[$PROVIDER =="ibm"]]
then
  awk '1;/API_URL=/{ print "subscription-manager refresh"; print "subscription-manager repos --enable=*";}' $path  > addhost.sh
elif [[$PROVIDER =="aws"]]
then
  awk '1;/API_URL=/{ print "yum update -y"; print "yum-config-manager --enable \x27*\x27"; print "yum repolist all"; print "yum install container-selinux -y";}' $path  > addhost.sh
fi
