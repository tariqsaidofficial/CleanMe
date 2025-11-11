#!/bin/bash

# Notarize the application for distribution outside the Mac App Store

# Variables
APP_PATH="path/to/your/app/CleanME.app"  # Update this to the path of your app
APPLE_ID="your_apple_id@example.com"     # Your Apple ID
APP_SPECIFIC_PASSWORD="your_app_specific_password"  # App-specific password for notarization
NOTARIZATION_UUID=""

# Step 1: Submit the app for notarization
echo "Submitting the app for notarization..."
NOTARIZATION_OUTPUT=$(xcrun altool --notarize-app --primary-bundle-id "com.yourcompany.CleanME" --username "$APPLE_ID" --password "$APP_SPECIFIC_PASSWORD" --file "$APP_PATH" --output-format xml)

# Extract the UUID from the output
NOTARIZATION_UUID=$(echo "$NOTARIZATION_OUTPUT" | grep -o 'RequestUUID="[^"]*' | cut -d'"' -f2)

if [ -z "$NOTARIZATION_UUID" ]; then
    echo "Failed to submit for notarization."
    exit 1
fi

echo "Notarization request submitted. UUID: $NOTARIZATION_UUID"

# Step 2: Check the notarization status
echo "Checking notarization status..."
while true; do
    STATUS_OUTPUT=$(xcrun altool --notarization-info "$NOTARIZATION_UUID" --username "$APPLE_ID" --password "$APP_SPECIFIC_PASSWORD" --output-format xml)
    STATUS=$(echo "$STATUS_OUTPUT" | grep -o '<status>[^<]*' | cut -d'>' -f2)

    echo "Notarization status: $STATUS"

    if [ "$STATUS" == "success" ]; then
        echo "Notarization successful!"
        break
    elif [ "$STATUS" == "invalid" ]; then
        echo "Notarization failed."
        exit 1
    fi

    sleep 30  # Wait before checking again
done

# Step 3: Staple the notarization ticket to the app
echo "Stapling the notarization ticket to the app..."
xcrun stapler staple "$APP_PATH"

echo "Notarization process completed successfully."