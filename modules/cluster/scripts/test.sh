export LOCATION="aws-us-east-1-nvirginia-z3"
export cluster_name="aws-us-east-1-nvirginia-z3-roks1"
export API_KEY=$(security find-generic-password -a ${USER} -s zgleason-naboo-qa -w)
export REGION="us-east"
export RESOURCE_GROUP="Default"
export ENDPOINT="cloud.ibm.com"

./cluster.sh
