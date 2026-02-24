#!/bin/sh

# Fail this script if any subcommand fails
set -e

echo "Setting build number to $CI_BUILD_NUMBER..."

# Update the build number in Info.plist
cd "$CI_PRIMARY_REPOSITORY_PATH/ios"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $CI_BUILD_NUMBER" "Runner/Info.plist"

echo "Build number set to $CI_BUILD_NUMBER"
