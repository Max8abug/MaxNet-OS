#!/usr/bin/env bash
set -euo pipefail

BASE_URL="__MAXOS_DOWNLOAD_ORIGIN__"
OUTPUT_NAME="MaxOS-0.4.6-cinnamon-64bit.iso"
EXPECTED_SIZE=3088973824
EXPECTED_SHA256="ebead706a9a41c5c161ceacb37d076a4fc4e955b03a0c4119313fc18a6e1b1a9"
CHUNK_SIZE=268435456
CHUNK_COUNT=$(((EXPECTED_SIZE + CHUNK_SIZE - 1) / CHUNK_SIZE))
OUTPUT_DIR="${OUTPUT_DIR:-$PWD}"
OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_NAME"
PARTIAL_PATH="$OUTPUT_PATH.partial"
TEMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf -- "$TEMP_DIR"
}
trap cleanup EXIT

if [[ -e "$OUTPUT_PATH" ]]; then
  echo "Destination already exists: $OUTPUT_PATH" >&2
  echo "Move or rename it before running this downloader." >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required but was not found." >&2
  exit 1
fi

rm -f -- "$PARTIAL_PATH"
: > "$PARTIAL_PATH"

for ((part = 1; part <= CHUNK_COUNT; part++)); do
  start=$(((part - 1) * CHUNK_SIZE))
  expected_part_size=$CHUNK_SIZE
  remaining=$((EXPECTED_SIZE - start))
  if ((remaining < CHUNK_SIZE)); then
    expected_part_size=$remaining
  fi

  part_path="$TEMP_DIR/maxos-part-$part.bin"
  part_url="$BASE_URL/api/download/maxnet-os.part/$part"
  downloaded=0

  echo "Downloading chunk $part of $CHUNK_COUNT..."
  for attempt in 1 2 3 4 5 6; do
    rm -f -- "$part_path"
    if curl --fail --silent --show-error --location --output "$part_path" "$part_url"; then
      actual_part_size="$(stat -c '%s' -- "$part_path")"
      if [[ "$actual_part_size" == "$expected_part_size" ]]; then
        downloaded=1
        break
      fi
    fi

    if ((attempt < 6)); then
      echo "Chunk $part failed on attempt $attempt; retrying..." >&2
      sleep 2
    fi
  done

  if ((downloaded == 0)); then
    echo "Could not download chunk $part after 6 attempts." >&2
    echo "Rerun this script to restart the download." >&2
    exit 1
  fi

  cat -- "$part_path" >> "$PARTIAL_PATH"
done

actual_size="$(stat -c '%s' -- "$PARTIAL_PATH")"
if [[ "$actual_size" != "$EXPECTED_SIZE" ]]; then
  echo "Assembled ISO has $actual_size bytes; expected $EXPECTED_SIZE." >&2
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
