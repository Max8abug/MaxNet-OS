$ErrorActionPreference = "Stop"

$BaseUrl = "__MAXOS_DOWNLOAD_ORIGIN__"
$OutputName = "MaxOS-0.4.6-cinnamon-64bit.iso"
$ExpectedSize = 3088973824L
$ExpectedSha256 = "ebead706a9a41c5c161ceacb37d076a4fc4e955b03a0c4119313fc18a6e1b1a9"
$ChunkSize = 256MB
$ChunkCount = [int][Math]::Ceiling($ExpectedSize / $ChunkSize)
$OutputPath = Join-Path $PSScriptRoot $OutputName
$PartialPath = "$OutputPath.partial"

if (Test-Path -LiteralPath $OutputPath) {
    throw "The destination already exists: $OutputPath. Rename or move it before running this downloader."
}

if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
    throw "curl.exe was not found. Use a current Windows version with curl included."
}

if (Test-Path -LiteralPath $PartialPath) {
    Remove-Item -LiteralPath $PartialPath -Force
}

$OutputStream = [System.IO.File]::Open(
    $PartialPath,
    [System.IO.FileMode]::CreateNew,
    [System.IO.FileAccess]::Write,
    [System.IO.FileShare]::None
)

try {
    for ($part = 1; $part -le $ChunkCount; $part++) {
        $start = [long](($part - 1) * $ChunkSize)
        $expectedPartSize = [Math]::Min([long]$ChunkSize, $ExpectedSize - $start)
        $partPath = Join-Path $env:TEMP "maxos-0.4.6-part-$PID-$part.bin"
        $partUrl = "$BaseUrl/api/download/maxnet-os.part/$part"

        Write-Host "Downloading chunk $part of $ChunkCount..."
        try {
            $downloaded = $false
            for ($attempt = 1; $attempt -le 6; $attempt++) {
                if (Test-Path -LiteralPath $partPath) {
                    Remove-Item -LiteralPath $partPath -Force
                }

                & curl.exe --fail --silent --show-error --location `
                    --output $partPath $partUrl
                $curlExitCode = $LASTEXITCODE

                if ($curlExitCode -eq 0 -and (Test-Path -LiteralPath $partPath)) {
                    $actualPartSize = (Get-Item -LiteralPath $partPath).Length
                    if ($actualPartSize -eq $expectedPartSize) {
                        $downloaded = $true
                        break
                    }
                }

                if ($attempt -lt 6) {
                    Write-Warning "Chunk $part failed on attempt $attempt; retrying."
                    Start-Sleep -Seconds 2
                }
            }

            if (-not $downloaded) {
                throw "Could not download chunk $part after 6 attempts."
            }

            $PartStream = [System.IO.File]::OpenRead($partPath)
            try {
                $PartStream.CopyTo($OutputStream)
                $OutputStream.Flush()
            }
            finally {
                $PartStream.Dispose()
            }
        }
        finally {
            if (Test-Path -LiteralPath $partPath) {
                Remove-Item -LiteralPath $partPath -Force
            }
        }
    }
}
finally {
    $OutputStream.Dispose()
}

$actualSize = (Get-Item -LiteralPath $PartialPath).Length
if ($actualSize -ne $ExpectedSize) {
    throw "The assembled ISO has $actualSize bytes; expected $ExpectedSize. The partial file was kept for diagnosis."
}

$actualSha256 = (Get-FileHash -LiteralPath $PartialPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualSha256 -ne $ExpectedSha256) {
    throw "Checksum mismatch. Expected $ExpectedSha256 but got $actualSha256. The partial file was kept for diagnosis."
}

Move-Item -LiteralPath $PartialPath -Destination $OutputPath
Write-Host "Download complete: $OutputPath"
Write-Host "SHA-256: $actualSha256"
