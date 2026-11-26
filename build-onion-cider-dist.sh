#!/bin/sh

SCHEME="Reynard"
PROJECT_NAME="Onion Cider"
PROJECT="browser/Reynard.xcodeproj"
BUILD_DIR="./dist"
DEST_DIR="$HOME/Desktop/"

ARCHIVE_PATH="$BUILD_DIR/$PROJECT_NAME.xcarchive"
PAYLOAD_DIR="$BUILD_DIR/Payload"
ZIP_NAME="$PROJECT_NAME.ipa"

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

cp -a "$ARCHIVE_PATH/Products/Applications/$PROJECT_NAME.app" "$PAYLOAD_DIR/"

cd "$BUILD_DIR"
zip -r -9 "$ZIP_NAME" "Payload"

mv "$ZIP_NAME" "$DEST_DIR"


echo "- Done. IPA ready at: '${DEST_DIR}${ZIP_NAME}'"
