#!/bin/bash

SERVICE_NAME="${SERVICE_NAME}"
COMPONENT="${COMPONENT}"
TARGET_DIR="infrastructure/components/$COMPONENT"

echo "SourcesDirectory: $SOURCES_DIR"
echo "Correct service-repo location: $SOURCES_DIR/../service-repo"

echo "Changing to service-repo..."
cd "$SOURCES_DIR/../service-repo"

git config --global user.email "NotificationBot@maps.org.uk"
git config --global user.name "Notification Bot"

cd $TARGET_DIR
current_revision=$(grep 'revision' $TF_FILE | awk -F'= ' '{print $2}' | tr -d '"')

next_revision=$((current_revision + 1))
echo "Current API Revision: $current_revision"
echo "Next API Revision: $next_revision"

awk -v new_revision="$next_revision" '/revision[[:space:]]*=/ {sub(/"[^"]*"/, "\"" new_revision "\"")} 1' $TF_FILE > temp && mv temp $TF_FILE

git fetch origin
git checkout -b update-spec
git add $TF_FILE
git commit -m "Bump API revision to $next_revision"
git push -f https://$PAT_TOKEN@dev.azure.com/moneyandpensionsservice/MaPS%20Digital/_git/$AZURE_REPO HEAD:update-spec
az repos pr create --repository "$AZURE_REPO" --target-branch develop --source-branch update-spec --title "Update OpenAPI spec" --bypass-policy true --delete-source-branch true --draft false
