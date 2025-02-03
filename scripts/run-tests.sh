#!/bin/bash
set -e

if [ "$#" -eq 0 ]; then
    echo "❌ No test locations provided!"
    exit 1
fi

# Install system dependencies
sudo apt-get update -qq
sudo apt-get install -y lcov

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
    sed -i "s|SF:$(pwd)/|SF:|g" "coverage/$MODULE_NAME/lcov.info"
    if [ "$MODULE_PATH" != "." ]; then
        sed -i "s|^SF:lib/|SF:$MODULE_PATH/lib/|g" "coverage/$MODULE_NAME/lcov.info"
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