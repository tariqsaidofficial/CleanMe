#!/bin/bash

# CleanME Build Script

# Exit immediately if a command exits with a non-zero status
set -e

# Define the build directory
BUILD_DIR="build"

# Create the build directory if it doesn't exist
mkdir -p $BUILD_DIR

# Build the application using Swift Package Manager
echo "Building the CleanME application..."
swift build -c release -o $BUILD_DIR/CleanME

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Build successful! The application is located at: $BUILD_DIR/CleanME"
else
    echo "Build failed. Please check the errors above."
    exit 1
fi

# Optionally, you can add additional steps here, such as running tests or generating documentation.