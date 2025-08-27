@echo off
echo Running PayE Dart Example...
echo ==============================

REM Check if Dart is installed
dart --version >nul 2>&1
if errorlevel 1 (
    echo Error: Dart SDK is not installed or not in PATH
    echo Please install Dart SDK from https://dart.dev/get-dart
    pause
    exit /b 1
)

REM Get dependencies
echo Getting dependencies...
dart pub get

REM Run the example
echo Running example...
dart run example/example.dart

echo.
echo Example completed!
pause
