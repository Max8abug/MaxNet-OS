#!/usr/bin/env bash
set -euo pipefail

INITRAMFS="${1:?Usage: brand-initramfs.sh INITRAMFS ROOTFS}"
ROOTFS="${2:?Usage: brand-initramfs.sh INITRAMFS ROOTFS}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

for command_name in python3 zstd; do
  command -v "$command_name" >/dev/null 2>&1 || {
    printf 'Required initramfs branding tool not found: %s\n' "$command_name" >&2
    exit 1
  }
done
test -f "$INITRAMFS"
test -d "$ROOTFS/usr/share/plymouth/themes/mint-logo"

python3 - "$INITRAMFS" "$WORK" <<'PY'
from pathlib import Path
import sys

archive = Path(sys.argv[1]).read_bytes()
work = Path(sys.argv[2])
align = lambda value: (value + 3) & ~3
position = 0
archive_count = 0

while position < len(archive):
    while position < len(archive) and archive[position] == 0:
        position += 1
    if archive[position:position + 6] not in (b"070701", b"070702"):
        break

    archive_count += 1
    found_trailer = False
    while position + 110 <= len(archive):
        header = archive[position:position + 110]
        if header[:6] not in (b"070701", b"070702"):
            break
        try:
            size = int(header[54:62], 16)
            name_size = int(header[94:102], 16)
        except ValueError as error:
            raise SystemExit("Invalid CPIO header in initramfs") from error
        if name_size < 1:
            raise SystemExit("Invalid CPIO filename in initramfs")
        name_start = position + 110
        name = archive[name_start:name_start + name_size - 1].decode(
            "utf-8", "surrogateescape"
        )
        data_start = align(name_start + name_size)
        position = align(data_start + size)
        if position > len(archive):
            raise SystemExit(f"Truncated CPIO entry in initramfs: {name}")
        if name == "TRAILER!!!":
            found_trailer = True
            break
    if not found_trailer:
        raise SystemExit("Could not find the end of a prepended CPIO archive")

if archive_count == 0 or position >= len(archive):
    raise SystemExit("Could not locate the compressed main initramfs archive")
if archive[position:position + 4] != bytes.fromhex("28b52ffd"):
    raise SystemExit("Expected a Zstandard-compressed main initramfs archive")

(work / "prefix").write_bytes(archive[:position])
(work / "main.zst").write_bytes(archive[position:])
print(f"Found {archive_count} prepended CPIO archive(s)")
PY

zstd -q -d -c "$WORK/main.zst" > "$WORK/main.cpio"

python3 - "$WORK" "$ROOTFS" <<'PY'
from pathlib import Path
import sys

work = Path(sys.argv[1])
root = Path(sys.argv[2])
source = (work / "main.cpio").read_bytes()
theme = root / "usr/share/plymouth/themes/mint-logo"
replacements = {
    "usr/share/plymouth/themes/mint-logo/mint-logo.plymouth":
        (theme / "mint-logo.plymouth").read_bytes(),
    "usr/share/plymouth/themes/mint-logo/bgrt-fallback.png":
        (theme / "bgrt-fallback.png").read_bytes(),
}
for frame in range(1, 37):
    filename = f"animation-{frame:04}.png"
    replacements[f"usr/share/plymouth/themes/mint-logo/{filename}"] = (
        theme / filename
    ).read_bytes()

align = lambda value: (value + 3) & ~3
output = bytearray()
position = 0
replaced = set()
while position + 110 <= len(source):
    header = bytearray(source[position:position + 110])
    if header[:6] not in (b"070701", b"070702"):
        raise SystemExit("Main initramfs is not a newc CPIO archive")
    size = int(header[54:62], 16)
    name_size = int(header[94:102], 16)
    name_start = position + 110
    name = source[name_start:name_start + name_size - 1].decode(
        "utf-8", "surrogateescape"
    )
    data_start = align(name_start + name_size)
    entry_end = align(data_start + size)
    if entry_end > len(source):
        raise SystemExit(f"Truncated CPIO entry in main initramfs: {name}")

    if name in replacements:
        payload = replacements[name]
        header[54:62] = f"{len(payload):08x}".encode()
        entry = bytearray(header)
        entry.extend(source[name_start:name_start + name_size])
        entry.extend(b"\0" * (align(len(entry)) - len(entry)))
        entry.extend(payload)
        entry.extend(b"\0" * (align(len(entry)) - len(entry)))
        output.extend(entry)
        replaced.add(name)
    else:
        output.extend(source[position:entry_end])

    position = entry_end
    if name == "TRAILER!!!":
        break
else:
    raise SystemExit("Main initramfs CPIO archive has no trailer")

missing = sorted(set(replacements) - replaced)
if missing:
    raise SystemExit("Plymouth assets missing from initramfs: " + ", ".join(missing))
output.extend(source[position:])
(work / "main-maxos.cpio").write_bytes(output)
print(f"Updated {len(replaced)} MaxOS Plymouth assets in the initramfs")
PY

zstd -q -3 -c "$WORK/main-maxos.cpio" > "$WORK/main-maxos.zst"
zstd -q -t "$WORK/main-maxos.zst"

python3 - "$INITRAMFS" "$WORK" <<'PY'
from pathlib import Path
import os
import stat
import sys

initramfs = Path(sys.argv[1])
work = Path(sys.argv[2])
metadata = initramfs.stat()
rebuilt = (work / "prefix").read_bytes() + (work / "main-maxos.zst").read_bytes()
temporary = initramfs.with_name(initramfs.name + ".maxos-tmp")
temporary.write_bytes(rebuilt)
os.chmod(temporary, stat.S_IMODE(metadata.st_mode))
os.utime(temporary, ns=(metadata.st_atime_ns, metadata.st_mtime_ns))
os.replace(temporary, initramfs)
print(f"Branded MaxOS Plymouth splash in {initramfs}")
PY
