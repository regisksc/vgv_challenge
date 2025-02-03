#!/bin/bash
set -eo pipefail  # Exit immediately on errors and pipeline failures

# Validate input parameters
if [ $# -eq 0 ]; then
  echo "❌ Error: No target directories provided!"
  echo "Usage: $0 <directory1> <directory2> ..."
  exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
METRICS_DIR="$PROJECT_ROOT/metrics"
REPORT_DATE=$(date +%Y-%m-%d)                # Current date for report versioning
HTML_DIR="$METRICS_DIR/html"                 # Temporary HTML output directory
REPORT_DIR="$METRICS_DIR/report_$REPORT_DATE" # Final dated report directory
LOG_FILE="$METRICS_DIR/metrics_$REPORT_DATE.log" # Analysis log file

echo "📊 Initializing Dart Code Metrics Analysis..."
mkdir -p "$HTML_DIR"

# Validate and convert input directories
declare -a TARGET_DIRS=()
for dir in "$@"; do
  # Check if directory exists relative to project root
  if [ ! -d "$PROJECT_ROOT/$dir" ]; then
    echo "❌ Error: Directory '$dir' does not exist in project!"
    echo "Available directories:"
    (cd "$PROJECT_ROOT" && find . -type d)
    exit 1
  fi
  
  # Convert to absolute path
  abs_dir="$(cd "$PROJECT_ROOT/$dir" && pwd)"
  TARGET_DIRS+=("$abs_dir")
done

echo "🔧 Installing Dart Code Metrics..."
flutter pub global activate dart_code_metrics > /dev/null # Silent install

echo "🔍 Running comprehensive code analysis..."
{
  # Run metrics analysis with HTML reporter
  flutter pub global run dart_code_metrics:metrics \
    --reporter=html \
    --output-directory="$HTML_DIR" \
    --disable-sunset-warning \
    --fatal-performance \
    --exclude="{**.g.dart,**.gen.dart,**.freezed.dart,**/*test.dart}" \
    --root-folder="$PROJECT_ROOT" \
    "${TARGET_DIRS[@]}" # Analyzed directories
} 2>&1 | tee "$LOG_FILE" # Save output to log

echo "📈 Generating final report..."
if [ -d "$HTML_DIR" ]; then
  # Move and rename the HTML output to dated directory
  mv "$HTML_DIR" "$REPORT_DIR"
  echo "✅ Full report generated: $REPORT_DIR/index.html"
else
  echo "❌ Error: HTML directory not found!"
  exit 1
fi