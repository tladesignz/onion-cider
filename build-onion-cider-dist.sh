#!/bin/bash

# Configuration
CONFIG_FILE="browser/Configuration/Reynard.xcconfig"
SCHEME="Reynard"
PROJECT="browser/Reynard.xcodeproj"
BUILD_DIR="./dist"
DEST_DIR="$HOME/Desktop"


# More configuration from $CONFIG_FILE
get_cfg() {
    grep "^$1 =" "$CONFIG_FILE" | cut -d'=' -f2 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

PROJECT_NAME=$(get_cfg "APP_DISPLAY_NAME")
VERSION=$(get_cfg "CURRENT_VERSION")
BUILD_VERSION=$(get_cfg "CURRENT_BUILD")

if [ -z "$PROJECT_NAME" ]; then
    echo "- Error: APP_DISPLAY_NAME not found in $CONFIG_FILE";
    exit 1
fi


# Derived paths
ARCHIVE_PATH="$BUILD_DIR/$PROJECT_NAME.xcarchive"
PAYLOAD_DIR="$BUILD_DIR/Payload"
ZIP_NAME="$PROJECT_NAME.ipa"
IPA_PATH="$DEST_DIR/$ZIP_NAME"

echo "- Prepare build environment…"

BASE=$(dirname "$0")
cd "$BASE"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"


echo "- Archive '$SCHEME' to '$ARCHIVE_PATH'…"

xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath "$ARCHIVE_PATH" \
    CODE_SIGNING_ALLOWED=NO

if [ $? -ne 0 ]; then
    echo "- Error. Archiving failed."
    exit 1
fi


echo "- Prepare IPA…"

mkdir -p "$PAYLOAD_DIR"

mv "$ARCHIVE_PATH/Products/Applications/$PROJECT_NAME.app" "$PAYLOAD_DIR/"

cd "$BUILD_DIR"
zip -r -9 "$ZIP_NAME" "Payload"

mv "$ZIP_NAME" "$DEST_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%d")

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)
CHANGELOG=$(git log "$LAST_TAG..HEAD" --pretty=format:"%s" | \
            head -n 12 | \
            sed 's/^/- /' | \
            sed 's/"/\\"/g' | \
            awk '{printf "%s\\n", $0}' | \
            sed 's/\\n$//')

URL_NAME=$(echo "$PROJECT_NAME" | tr ' ' '.')

FILE_SIZE=$(stat -f%z "$IPA_PATH")

echo "------------------------------------------------------------------"
echo "COPY THIS INTO source.json:"
echo "------------------------------------------------------------------"
cat <<EOF
                {
                    "version": "$VERSION",
                    "buildVersion": "$BUILD_VERSION",
                    "date": "$TIMESTAMP",
                    "localizedDescription": "$CHANGELOG",
                    "downloadURL": "https://github.com/tladesignz/onion-cider/releases/download/$VERSION/$URL_NAME.ipa",
                    "size": $FILE_SIZE
                }
EOF
echo "------------------------------------------------------------------"


echo "- Done. IPA ready at: '$IPA_PATH'"
