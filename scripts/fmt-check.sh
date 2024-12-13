#!/bin/bash

ROOT_PATH=$(dirname "$(dirname "$(realpath "$0")")")
TF_FILES=$(find "$ROOT_PATH" -type f -name "*.tf")

if [[ -z "$TF_FILES" ]]; then
    echo "No Terraform files found in this folder."
    exit 0
fi

# Check for empty files
for FILE in $TF_FILES; do
    if [[ ! -s "$FILE" ]]; then
        echo "Error: File $FILE is empty."
        exit 1
    fi
done

# Check for linting errors
DIRS=$(dirname $TF_FILES | sort -u)
for DIR in $DIRS; do
    terraform fmt -check=true "$DIR"
    if [[ $? -ne 0 ]]; then
        echo "Linting errors in directory $DIR."
        exit 1
    fi
done

echo "All checks passed!"
