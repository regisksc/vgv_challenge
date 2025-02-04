#!/bin/bash
set -e

# Function to detect the operating system
detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macOS"
  else
    echo "Unsupported OS"
  fi
}

# Function to check if lcov is already installed
is_lcov_installed() {
  if command -v lcov &> /dev/null; then
    echo "lcov is already installed."
    return 0
  else
    echo "lcov is not installed."
    return 1
  fi
}

# Detect the OS
OS=$(detect_os)

# Check if lcov is already installed
if is_lcov_installed; then
  echo "Skipping installation as lcov is already installed."
else
  # Install lcov based on the OS
  if [[ "$OS" == "Linux" ]]; then
    echo "Detected Linux. Installing lcov using apt-get..."
    sudo apt-get update -qq
    sudo apt-get install -y lcov
  elif [[ "$OS" == "macOS" ]]; then
    echo "Detected macOS. Installing lcov using Homebrew..."
    if ! command -v brew &> /dev/null; then
      echo "Homebrew is not installed. Please install Homebrew first."
      exit 1
    fi
    brew install lcov
  else
    echo "Unsupported operating system: $OS"
    exit 1
  fi
fi

# Verify installation
if ! is_lcov_installed; then
  echo "Failed to install lcov."
  exit 1
fi

# Setup coverage tools
flutter pub global activate remove_from_coverage

MODULES=("$@")
for MODULE_PATH in "${MODULES[@]}"; do
    MODULE_NAME=$(basename "$MODULE_PATH")
    [[ "$MODULE_PATH" == "." ]] && MODULE_NAME="app"
    echo "🧪 Testing: $MODULE_NAME ($MODULE_PATH)"
    
    # Install dependencies
    cd "$MODULE_PATH"
    flutter pub get
    cd -
    
    # Run tests with clean JSON output
    echo "⚡ Running tests in $MODULE_PATH"
    cd "$MODULE_PATH"
    flutter test --coverage --machine 2>/dev/null > test-results.json
    cd -
    
    # Process coverage
    mkdir -p "coverage/$MODULE_NAME"
    mv "$MODULE_PATH/coverage/lcov.info" "coverage/$MODULE_NAME/lcov.info"
    
    # Fix paths in lcov.info
    if [[ "$OS" == "macOS" ]]; then
        sed -i '' "s|SF:$(pwd)/|SF:|g" "coverage/$MODULE_NAME/lcov.info"
        if [ "$MODULE_PATH" != "." ]; then
            sed -i '' "s|^SF:lib/|SF:$MODULE_PATH/lib/|g" "coverage/$MODULE_NAME/lcov.info"
        fi
    else
        sed -i "s|SF:$(pwd)/|SF:|g" "coverage/$MODULE_NAME/lcov.info"
        if [ "$MODULE_PATH" != "." ]; then
            sed -i "s|^SF:lib/|SF:$MODULE_PATH/lib/|g" "coverage/$MODULE_NAME/lcov.info"
        fi
    fi
    
    # Generate HTML report
    genhtml "coverage/$MODULE_NAME/lcov.info" -o "coverage/$MODULE_NAME/html"
    
    # Clean coverage data
    flutter pub global run remove_from_coverage \
        -f "coverage/$MODULE_NAME/lcov.info" \
        -r 'generated|freezed|g\.dart'
    
    echo "✅ Completed: $MODULE_NAME"
done

# Merge coverage files
MERGE_CMD="lcov --add-tracefile coverage/app/lcov.info"
for MODULE in "${MODULES[@]}"; do
    [[ "$MODULE" == "." ]] && continue
    MOD_NAME=$(basename "$MODULE")
    MERGE_CMD+=" --add-tracefile coverage/${MOD_NAME}/lcov.info"
done
$MERGE_CMD -o coverage/merged.lcov.info

# Rename final directory
mv coverage coverage-reports