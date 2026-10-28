$ErrorActionPreference = "Stop"

$BaseUrl = "__MAXOS_DOWNLOAD_ORIGIN__"
$OutputName = "MaxOS-0.4.13-cinnamon-64bit.iso"
$ExpectedSize = 3088973824L
$ExpectedSha256 = "037a12c762d2f83652c86d369153a4829d9da3796e0afa3611a311f3a9aab1fb"
$OutputPath = Join-Path $PSScriptRoot $OutputName
$PartialPath = "$OutputPath.partial"

if (Test-Path -LiteralPath $OutputPath) {
    throw "The destination already exists: $OutputPath. Rename or move it before running this downloader."
}

if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
    throw "curl.exe was not found. Use a current Windows version with curl included."
}

$actualSize = 0L
if (Test-Path -LiteralPath $PartialPath) {
    $actualSize = (Get-Item -LiteralPath $PartialPath).Length
    if ($actualSize -gt $ExpectedSize) {
        throw "The partial file is larger than the expected ISO. Move it aside before retrying."
    }
}

if ($actualSize -lt $ExpectedSize) {
    Write-Host "Downloading the full ISO to $PartialPath (resumes if interrupted)..."
    & curl.exe --fail --location --retry 5 --retry-all-errors --continue-at - `
        --output $PartialPath --progress-bar "$BaseUrl/api/download/maxnet-os.iso"
    $curlExitCode = $LASTEXITCODE
    if ($curlExitCode -ne 0) {
        throw "Download interrupted. Keep the .partial file and rerun this script to resume."
    }
}

$actualSize = (Get-Item -LiteralPath $PartialPath).Length
if ($actualSize -ne $ExpectedSize) {
    throw "The downloaded ISO has $actualSize bytes; expected $ExpectedSize. The partial file was kept for diagnosis."
}

$actualSha256 = (Get-FileHash -LiteralPath $PartialPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualSha256 -ne $ExpectedSha256) {
    throw "Checksum mismatch. Expected $ExpectedSha256 but got $actualSha256. The partial file was kept for diagnosis."
}

Move-Item -LiteralPath $PartialPath -Destination $OutputPath
Write-Host "Download complete: $OutputPath"
Write-Host "SHA-256: $actualSha256"
