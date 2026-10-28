#!/usr/bin/env bash
set -euo pipefail

BASE_URL="__MAXOS_DOWNLOAD_ORIGIN__"
OUTPUT_NAME="MaxOS-0.4.10-cinnamon-64bit.iso"
EXPECTED_SIZE=3088973824
EXPECTED_SHA256="1b51c82649cb9533fc7a8beb9ca28aeaf26679c6f8bb027eb79b15392d53a875"
OUTPUT_DIR="${OUTPUT_DIR:-$PWD}"
OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_NAME"
PARTIAL_PATH="$OUTPUT_PATH.partial"

if [[ -e "$OUTPUT_PATH" ]]; then
  echo "Destination already exists: $OUTPUT_PATH" >&2
  echo "Move or rename it before running this downloader." >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required but was not found." >&2
  exit 1
fi

mkdir -p -- "$OUTPUT_DIR"
actual_size=0
if [[ -e "$PARTIAL_PATH" ]]; then
  actual_size="$(stat -c '%s' -- "$PARTIAL_PATH")"
  if ((actual_size > EXPECTED_SIZE)); then
    echo "Partial file is larger than the expected ISO; move it aside before retrying." >&2
    exit 1
  fi
fi

if ((actual_size < EXPECTED_SIZE)); then
  echo "Downloading the full ISO to $PARTIAL_PATH (resumes if interrupted)..."
  if ! curl --fail --location --retry 5 --retry-all-errors --continue-at - \
    --output "$PARTIAL_PATH" --progress-bar "$BASE_URL/api/download/maxnet-os.iso"; then
    echo "Download interrupted. Keep the .partial file and rerun this script to resume." >&2
    exit 1
  fi
fi

actual_size="$(stat -c '%s' -- "$PARTIAL_PATH")"
if [[ "$actual_size" != "$EXPECTED_SIZE" ]]; then
  echo "Downloaded ISO has $actual_size bytes; expected $EXPECTED_SIZE." >&2
  echo "The partial file was kept for diagnosis." >&2
  exit 1
fi

actual_sha256="$(sha256sum -- "$PARTIAL_PATH" | awk '{print $1}')"
if [[ "$actual_sha256" != "$EXPECTED_SHA256" ]]; then
  echo "Checksum mismatch: expected $EXPECTED_SHA256, got $actual_sha256." >&2
  echo "The partial file was kept for diagnosis." >&2
  exit 1
fi

mv -- "$PARTIAL_PATH" "$OUTPUT_PATH"
echo "Download complete: $OUTPUT_PATH"
echo "SHA-256: $actual_sha256"
