#!/usr/bin/env bash
# Build CubeRunOverDrive.ipa for Sideloadly (run on Mac with Xcode).
#
# Usage:
#   ./scripts/build-ipa-sideloadly.sh              # unsigned IPA — Sideloadly signs on install
#   ./scripts/build-ipa-sideloadly.sh AB12CD34EF   # signed development IPA (your Team ID)
#
set -euo pipefail

TEAM_ID="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_DIR="$ROOT_DIR/CubeRunOverDrive"
PROJECT="$PROJECT_DIR/CubeRunOverDrive.xcodeproj"
SCHEME="CubeRunOverDrive"
OUT_DIR="$ROOT_DIR/build/sideloadly"
IPA_NAME="CubeRunOverDrive.ipa"

if [[ ! -d "$PROJECT" ]]; then
  echo "error: project not found at $PROJECT" >&2
  exit 1
fi

if ! command -v xcodebuild >/dev/null; then
  echo "error: xcodebuild not found. Install Xcode and run:" >&2
  echo "  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer" >&2
  exit 1
fi

cd "$PROJECT_DIR"
mkdir -p "$OUT_DIR"

echo "==> Building Release for iOS (iphoneos)…"

if [[ -n "$TEAM_ID" ]]; then
  echo "    Mode: signed export (Team ID: $TEAM_ID)"
  ARCHIVE_PATH="$OUT_DIR/CubeRunOverDrive.xcarchive"
  EXPORT_DIR="$OUT_DIR/export"
  EXPORT_PLIST="$OUT_DIR/ExportOptions.plist"

  sed "s/TEAM_ID_PLACEHOLDER/$TEAM_ID/g" "$SCRIPT_DIR/ExportOptions-Sideloadly.plist" > "$EXPORT_PLIST"

  xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    CODE_SIGN_STYLE=Automatic \
    archive

  rm -rf "$EXPORT_DIR"
  xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_DIR" \
    -exportOptionsPlist "$EXPORT_PLIST" \
    -allowProvisioningUpdates

  IPA_SRC=$(find "$EXPORT_DIR" -maxdepth 1 -name "*.ipa" | head -1)
  if [[ -z "$IPA_SRC" ]]; then
    echo "error: export did not produce an .ipa" >&2
    exit 1
  fi
  cp "$IPA_SRC" "$OUT_DIR/$IPA_NAME"
else
  echo "    Mode: unsigned IPA (Sideloadly will sign with your Apple ID)"
  DERIVED="$OUT_DIR/DerivedData"

  xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -derivedDataPath "$DERIVED" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    build

  APP=$(find "$DERIVED" -name "CubeRunOverDrive.app" -path "*Release-iphoneos*" | head -1)
  if [[ -z "$APP" || ! -d "$APP" ]]; then
    echo "error: CubeRunOverDrive.app not found under $DERIVED" >&2
    exit 1
  fi

  PAYLOAD_DIR="$OUT_DIR/Payload"
  rm -rf "$PAYLOAD_DIR" "$OUT_DIR/$IPA_NAME"
  mkdir -p "$PAYLOAD_DIR"
  cp -R "$APP" "$PAYLOAD_DIR/"

  (cd "$OUT_DIR" && zip -qr "$IPA_NAME" Payload)
  rm -rf "$PAYLOAD_DIR"
fi

echo ""
echo "==> Done."
echo "    IPA: $OUT_DIR/$IPA_NAME"
echo ""
echo "Sideloadly:"
echo "  1. Open Sideloadly on your Mac/PC"
echo "  2. Drag $OUT_DIR/$IPA_NAME onto it"
echo "  3. Enter your Apple ID"
echo "  4. Connect iPhone (USB) and click Start"
echo ""
