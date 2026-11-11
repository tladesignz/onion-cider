#!/bin/bash
#  fix-ios27.sh
#  Reynard
#
#  Created by Benjamin Erhart on 19.10.26.
#

# Exit on any error
set -e

# --- Configuration ---
SDK_ROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.2.sdk"
# The pattern to remove from the TBD files
PATTERN=", arm64e.x1-ios"

# List of files relative to SDK_ROOT
LIBS=(
    "usr/lib/libSystem.B.tbd"
    "usr/lib/libc++.1.tbd"
    "System/Library/Frameworks/Accelerate.framework/Accelerate.tbd"
    "System/Library/Frameworks/CoreServices.framework/CoreServices.tbd"
    "System/Library/Frameworks/Accelerate.framework/Frameworks/vImage.framework/vImage.tbd"
    "System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/vecLib.tbd"
    "System/Library/Frameworks/Foundation.framework/Foundation.tbd"
    "System/Library/Frameworks/CoreFoundation.framework/CoreFoundation.tbd"
    "usr/lib/libobjc.A.tbd"
    "System/Library/Frameworks/Metal.framework/Metal.tbd"
    "System/Library/Frameworks/MetalKit.framework/MetalKit.tbd"
    "usr/lib/libresolv.9.tbd"
    "System/Library/Frameworks/CFNetwork.framework/CFNetwork.tbd"
    "System/Library/Frameworks/Network.framework/Network.tbd"
    "System/Library/Frameworks/MobileCoreServices.framework/MobileCoreServices.tbd"
    "System/Library/Frameworks/IOSurface.framework/IOSurface.tbd"
    "System/Library/Frameworks/AudioToolbox.framework/AudioToolbox.tbd"
    "System/Library/Frameworks/CoreMedia.framework/CoreMedia.tbd"
    "System/Library/Frameworks/VideoToolbox.framework/VideoToolbox.tbd"
    "System/Library/Frameworks/AVFoundation.framework/AVFoundation.tbd"
    "System/Library/Frameworks/CoreGraphics.framework/CoreGraphics.tbd"
    "System/Library/Frameworks/CoreVideo.framework/CoreVideo.tbd"
    "System/Library/Frameworks/IOKit.framework/Versions/A/IOKit.tbd"
    "System/Library/Frameworks/QuartzCore.framework/QuartzCore.tbd"
    "System/Library/Frameworks/UIKit.framework/UIKit.tbd"
    "System/Library/Frameworks/LocalAuthentication.framework/LocalAuthentication.tbd"
    "System/Library/Frameworks/Security.framework/Security.tbd"
    "System/Library/Frameworks/MediaPlayer.framework/MediaPlayer.tbd"
    "System/Library/Frameworks/CoreLocation.framework/CoreLocation.tbd"
    "System/Library/Frameworks/CoreMotion.framework/CoreMotion.tbd"
    "System/Library/Frameworks/CoreText.framework/CoreText.tbd"
    "System/Library/Frameworks/OpenGLES.framework/OpenGLES.tbd"
    "System/Library/Frameworks/AVFAudio.framework/AVFAudio.tbd"
    "System/Library/Frameworks/AVRouting.framework/AVRouting.tbd"
    "System/Library/Frameworks/FileProvider.framework/FileProvider.tbd"
    "System/Library/Frameworks/_LocationEssentials.framework/_LocationEssentials.tbd"
    "System/Library/Frameworks/CoreHaptics.framework/CoreHaptics.tbd"
    "System/Library/Frameworks/GameController.framework/GameController.tbd"
    "System/Library/Frameworks/CoreMIDI.framework/CoreMIDI.tbd"
)

# --- Functions ---

usage() {
    echo "Usage: sudo $0 [patch|undo]"
    echo "  patch: Removes incompatible arm64e.x1-ios architecture strings from SDK TBDs"
    echo "  undo:  Restores original TBD files from .bak files"
    exit 1
}

patch_libs() {
    echo "Starting patch process..."

    # Verify SDK root exists
    if [ ! -d "$SDK_ROOT" ]; then
        echo "Error: SDK root not found at $SDK_ROOT"
        echo "Please check if your Xcode version is correct."
        exit 1
    fi

    cd "$SDK_ROOT"

    for lib in "${LIBS[@]}"; do
        if [ -f "$lib.bak" ]; then
            echo "Skipping $lib: Backup already exists."
        elif [ -f "$lib" ]; then
            echo "Patching $lib..."
            cp -a "$lib" "$lib.bak"
            # MacOS sed requires the empty string '' after -i for in-place editing
            sed -i '' "s/$PATTERN//g" "$lib"
        else
            echo "Warning: $lib not found, skipping."
        fi
    done
    echo "Patching complete."
}

undo_libs() {
    echo "Starting undo process..."

    if [ ! -d "$SDK_ROOT" ]; then
        echo "Error: SDK root not found at $SDK_ROOT"
        exit 1
    fi

    cd "$SDK_ROOT"

    for lib in "${LIBS[@]}"; do
        if [ -f "$lib.bak" ]; then
            echo "Restoring $lib from backup..."
            mv "$lib.bak" "$lib"
        else
            echo "Skipping $lib: No backup file found."
        fi
    done
    echo "Undo complete."
}

# --- Main ---

# 1. Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo."
    exit 1
fi

# 2. Check for arguments
if [ $# -eq 0 ]; then
    usage
fi

case "$1" in
    patch)
        patch_libs
        ;;
    undo)
        undo_libs
        ;;
    *)
        usage
        ;;
esac
