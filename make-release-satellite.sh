#!/bin/sh
# make a tgz out of the terraform, modifying the paths to modules beforehand
# --dirname - where to do the worker
# --verison - version for the tgz name
# --cloud - aws, azure, or gcp
set -e

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dirname) RELEASE_DIR="$2"; shift ;;
        --version) RELEASE_VERSION="$2"; shift ;;
        --cloud) CLOUD="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$RELEASE_DIR" ]; then
  echo "dirname parameter is required"
  ERROR=true
fi

if [ -z "$RELEASE_VERSION" ]; then
  echo "version parameter is required"
  ERROR=true
fi

if [ -z "$CLOUD" ]; then
  echo "cloud parameter is required"
  ERROR=true
fi

if [ "$ERROR" = true ] ; then
  echo "exiting on error"
  exit 1
fi

case $CLOUD in 
  aws)
    CATALOG_NAME='satellite-aws'
    ;;
  azure)
    CATALOG_NAME='sat-azure'
    ;;
  gcp)
    CATALOG_NAME='satellite-gcp'
    ;;
  *)
    echo "Unknown cloud type. Cloud choices are aws, azure, gcp."
    exit 1
    ;;
esac

# remove refs/tags/ to get the version number
if [[ $RELEASE_VERSION == refs/tags/v* ]]; then
  RELEASE_VERSION=${RELEASE_VERSION:10}
fi

OUTPUT_DIR=releases/$RELEASE_DIR/$CLOUD/$CATALOG_NAME
TAR_NAME="$CLOUD-$RELEASE_VERSION.tgz"

echo "output directory: $OUTPUT_DIR"
echo "tar name: $TAR_NAME"
echo "catalog name is $CATALOG_NAME"

mkdir -p $OUTPUT_DIR
cp -r examples/satellite-$CLOUD/. $OUTPUT_DIR
cp -r modules $OUTPUT_DIR

# note, gnu sed. If on MacOS, use gsed or add '' after -i
sed -i 's#../../modules#./modules#g' $OUTPUT_DIR/*.tf

cd $OUTPUT_DIR/..
# chown should only be needed locally so username isn't in tar
# chown -R nobody s
echo `pwd`
tar -czf ../../$TAR_NAME $CATALOG_NAME
