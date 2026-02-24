#!/bin/sh

# Fail this script if any subcommand fails
set -e

echo "Installing Flutter..."

# Clone Flutter SDK
git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

echo "Creating .env file..."
cd "$CI_PRIMARY_REPOSITORY_PATH"
cat > .env << 'ENVEOF'
# CJ Affiliate API
CJ_API_TOKEN=t4hJM56wuY-QOK7YlWCsDf195A
CJ_WEBSITE_ID=7526658
CJ_COMPANY_ID=7865620
ENVEOF

echo "Running flutter pub get..."
flutter pub get

echo "Precaching iOS artifacts..."
flutter precache --ios

echo "Installing CocoaPods dependencies..."
cd "$CI_PRIMARY_REPOSITORY_PATH/ios"
pod install

echo "Post-clone script completed successfully!"
