#!/bin/bash

BUCKET_NAME="myappalb.logs77399957"

echo "Emptying bucket $BUCKET_NAME"

# Remove all objects
aws s3 rm s3://$BUCKET_NAME --recursive

# Delete all versions (if any)
VERSIONS=$(aws s3api list-object-versions --bucket $BUCKET_NAME --output=json --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')
if [ "$(echo $VERSIONS | jq '.Objects')" != "null" ] && [ "$(echo $VERSIONS | jq '.Objects | length')" -gt 0 ]; then
    echo "Deleting object versions..."
    aws s3api delete-objects --bucket $BUCKET_NAME --delete "$VERSIONS"
else
    echo "No object versions to delete."
fi

# Delete all delete markers (if any)
DELETE_MARKERS=$(aws s3api list-object-versions --bucket $BUCKET_NAME --output=json --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')
if [ "$(echo $DELETE_MARKERS | jq '.Objects')" != "null" ] && [ "$(echo $DELETE_MARKERS | jq '.Objects | length')" -gt 0 ]; then
    echo "Deleting delete markers..."
    aws s3api delete-objects --bucket $BUCKET_NAME --delete "$DELETE_MARKERS"
else
    echo "No delete markers to delete."
fi

echo "Bucket emptying process completed"
