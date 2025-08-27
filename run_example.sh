#!/bin/bash

echo "Running PayE Dart Example..."
echo "=============================="

# Check if Dart is installed
if ! command -v dart &> /dev/null; then
    echo "Error: Dart SDK is not installed or not in PATH"
    echo "Please install Dart SDK from https://dart.dev/get-dart"
    exit 1
fi

# Get dependencies
echo "Getting dependencies..."
dart pub get

# Run the example
echo "Running example..."
dart run example/example.dart

echo ""
echo "Example completed!"
