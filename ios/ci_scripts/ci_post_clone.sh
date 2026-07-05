#!/bin/sh

# Fail this script if any subcommand fails
set -e

echo "Installing Flutter..."

# Clone Flutter SDK, pinned to the version used for local development so CI
# resolves the same package/pod versions (the "stable" branch drifts over time).
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.38.9 "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

echo "Creating .env file..."
cd "$CI_PRIMARY_REPOSITORY_PATH"
cat > .env << ENVEOF
# CJ Affiliate API
CJ_API_TOKEN=${CJ_API_TOKEN}
CJ_WEBSITE_ID=${CJ_WEBSITE_ID}
CJ_COMPANY_ID=${CJ_COMPANY_ID}
ENVEOF

echo "Running flutter pub get..."
flutter pub get

echo "Precaching iOS artifacts..."
flutter precache --ios

echo "Installing CocoaPods dependencies..."
cd "$CI_PRIMARY_REPOSITORY_PATH/ios"
pod install

echo "Post-clone script completed successfully!"
