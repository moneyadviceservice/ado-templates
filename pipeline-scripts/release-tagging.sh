#!/bin/bash

git config --global user.email "NotificationBot@maps.org.uk"
git config --global user.name "Notification Bot"

echo "Fetching tags..."
git fetch --tags

latestTag=$(git tag --list 'v*' --sort=-v:refname | head -n 1)
if [ -z "$latestTag" ]; then
    latestTag="v0.0.0"
fi

echo "Latest tag: $latestTag"

versionRegex="^v([0-9]+)\.([0-9]+)\.([0-9]+)$"
if [[ $latestTag =~ $versionRegex ]]; then
    major=${BASH_REMATCH[1]}
    minor=${BASH_REMATCH[2]}
    patch=${BASH_REMATCH[3]}
else
    echo "Invalid tag format."
    exit 1
fi

bumpType='${{ parameters.versionBump }}'
echo "Bump type: $bumpType"

case "$bumpType" in
    patch)
    patch=$((patch + 1))
    ;;
    minor)
    minor=$((minor + 1))
    patch=0
    ;;
    major)
    major=$((major + 1))
    minor=0
    patch=0
    ;;
    *)
    echo "Invalid bump type: $bumpType"
    exit 1
    ;;
esac

            newTag="v$major.$minor.$patch"
            echo "New tag: $newTag"

            git tag -a $newTag -m "Release $newTag"
            git push origin $newTag