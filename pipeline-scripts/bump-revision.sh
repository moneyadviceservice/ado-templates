#!/bin/bash

SERVICE_NAME="${SERVICE_NAME}"
COMPONENT="${COMPONENT}"
TARGET_DIR="infrastructure/components/$COMPONENT"

echo "SourcesDirectory: $SOURCES_DIR"
echo "branch name is: $BRANCH_NAME"
echo "Correct service-repo location: $SOURCES_DIR/../service-repo"

echo "Cd to service-repo"
cd "$SOURCES_DIR/../service-repo"

git config --global user.email "NotificationBot@maps.org.uk"
git config --global user.name "Notification Bot"

echo "Log into Azure DevOps CLI"
export AZURE_DEVOPS_EXT_PAT=$AZURE_DEVOPS_EXT_PAT

az devops configure --defaults \
  organization=https://dev.azure.com/moneyandpensionsservice \
  project="MaPS Digital"

cd $TARGET_DIR
current_revision=$(grep 'revision' $TF_FILE | awk -F'= ' '{print $2}' | tr -d '"')

next_revision=$((current_revision + 1))
echo "Current API Revision: $current_revision"
echo "Next API Revision: $next_revision"

awk -v new_revision="$next_revision" '/revision[[:space:]]*=/ {sub(/"[^"]*"/, "\"" new_revision "\"")} 1' $TF_FILE > temp && mv temp $TF_FILE

# git pull origin $BRANCH_NAME
git pull origin main
git checkout -b update-spec
git branch --show-current
git add $TF_FILE
git commit -m "Bump API revision to $next_revision"
git push -f https://$PAT_TOKEN@dev.azure.com/moneyandpensionsservice/MaPS%20Digital/_git/$AZURE_REPO HEAD:refs/heads/update-spec
az repos pr create --repository "$AZURE_REPO" --target-branch main --source-branch update-spec --title "Update OpenAPI spec" --bypass-policy true --delete-source-branch true --draft false
