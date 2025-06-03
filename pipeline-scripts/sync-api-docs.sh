#!/bin/bash

set -euo pipefail

AZURE_ORG="moneyadviceservice"
AZURE_PROJECT="MaPS%20Digital"
AZURE_REPO="${AZURE_REPO}"
AZURE_PAT="${BOT_AZURE_PAT}"
AZURE_FILE_PATH="${AZURE_FILE_PATH}"

GITHUB_USER="maps-devops-bot"
GITHUB_EMAIL="NotificationBot@maps.org.uk"
GITHUB_REPO="api-docs"
GITHUB_BRANCH="main"
GITHUB_PAT="$BOT_GITHUB_PAT"

GITHUB_LOCAL_DIR="github_repo"
SERVICE_NAME="$AZURE_REPO"  # or set this explicitly
SPEC_FILE="$SPEC_FILE"

# Construct full path to your spec file in the checked out repo
SOURCE_PATH="${AZURE_FILE_PATH}"

echo "Service name: $SERVICE_NAME"
echo "Spec file path: $SOURCE_PATH"

# Debug info: show current directory and list files
pwd
ls -l
ls -l "$(dirname "$SOURCE_PATH")"

# Check if spec file exists
if [[ ! -f "$SOURCE_PATH" ]]; then
    echo "❌ Error: Spec file $SOURCE_PATH not found."
    exit 1
fi

# Configure git user
git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_USER"
git config --global init.defaultBranch main

# Clone GitHub repo to a local directory
echo "Cloning GitHub repo $GITHUB_REPO..."
git clone "https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${AZURE_ORG}/${GITHUB_REPO}.git" "$GITHUB_LOCAL_DIR"

# Define destination path for the spec inside GitHub repo
DEST_PATH="$GITHUB_LOCAL_DIR/specs/$SPEC_FILE"

# Make sure the specs directory exists
mkdir -p "$(dirname "$DEST_PATH")"

# Copy the spec file to the GitHub repo directory
cp "$SOURCE_PATH" "$DEST_PATH"

# Commit & push changes
cd "$GITHUB_LOCAL_DIR" || exit

git add "specs/$SPEC_FILE"

if git diff --cached --quiet; then
    echo "No changes to commit."
else
    git commit -m "Update $SERVICE_NAME spec"
    git push -f "https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${AZURE_ORG}/${GITHUB_REPO}.git" "$GITHUB_BRANCH"
fi
