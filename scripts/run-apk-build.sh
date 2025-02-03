#!/bin/bash
set -eo pipefail

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APK_DIR="$PROJECT_ROOT/apk"
BUILD_TYPE=${1:-release}
ENTRY_FILE="${2:-main_production.dart}"
FLAVOR=${3:-production}

# Debugging: Print environment variables (excluding sensitive info)
echo "🔍 Environment Variables:"
echo "ANDROID_KEYSTORE_PATH: $ANDROID_KEYSTORE_PATH"
echo "ANDROID_KEYSTORE_ALIAS: $ANDROID_KEYSTORE_ALIAS"
echo "BUILD_TYPE: $BUILD_TYPE"
echo "ENTRY_FILE: $ENTRY_FILE"
echo "FLAVOR: $FLAVOR"

# Validate build type
if [[ ! "$BUILD_TYPE" =~ ^(debug|release)$ ]]; then
  echo "❌ Error: Invalid build type '$BUILD_TYPE'. Use 'debug' or 'release'."
  exit 1
fi

# Validate entry file exists
if [ ! -f "$PROJECT_ROOT/lib/$ENTRY_FILE" ]; then
  echo "❌ Error: Entry file '$ENTRY_FILE' not found!"
  echo "Available files in lib/:"
  (cd "$PROJECT_ROOT/lib" && find . -name "*.dart")
  exit 1
fi

mkdir -p "$APK_DIR"

# Debugging: List the keystore file
echo "🔍 Listing keystore file:"
ls -la "$ANDROID_KEYSTORE_PATH"

# Debugging: List keystore aliases to verify the key exists
echo "🔍 Verifying keystore contents:"
keytool -list -v -keystore "$ANDROID_KEYSTORE_PATH" -alias "$ANDROID_KEYSTORE_ALIAS" -storepass "$ANDROID_KEYSTORE_PASSWORD" -keypass "$ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD" || {
  echo "❌ Error: Unable to access the key alias in the keystore. Please verify the alias and passwords."
  exit 1
}

echo "📦 Building $FLAVOR $BUILD_TYPE APK..."
flutter build apk \
  --$BUILD_TYPE \
  --target "lib/$ENTRY_FILE" \
  --flavor $FLAVOR \
  --dart-define=BUILD_TIMESTAMP="$(date +%s)" \
  --dart-define=BUILD_VERSION="$(git rev-parse --short HEAD)" \
  --split-debug-info="$APK_DIR/debug-info"

# Move APK to output directory
echo "📁 Organizing build artifacts..."
find "$PROJECT_ROOT/build/app/outputs/flutter-apk" -name "*.apk" -exec cp {} "$APK_DIR" \;

# Verify APK creation
APK_COUNT=$(ls -1 "$APK_DIR"/*.apk 2>/dev/null | wc -l)
if [ "$APK_COUNT" -eq 0 ]; then
  echo "❌ Error: No APK files generated!"
  exit 1
fi

# Generate version info
echo "📄 Generating build info..."
{
  echo "Build Type: $BUILD_TYPE"
  echo "Flavor: $FLAVOR"
  echo "Commit SHA: $(git rev-parse HEAD)"
  echo "Build Date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Flutter Version: $(flutter --version)"
} > "$APK_DIR/build-info.txt"

echo "✅ APK build completed successfully! Artifacts in: $APK_DIR"
ls -lh "$APK_DIR"
