# Extract the latest zipped json URL from caa.bg
$ErrorActionPreference = 'Stop'
$page = Invoke-WebRequest -Uri 'https://www.caa.bg/bg/category/633/7062' -UseBasicParsing
$matches = [regex]::Matches(
    $page.Content,
    'href="(/sites/default/files/upload/documents/[^"]+bgr_zones_[^"]+\.zip)"'
)
if ($matches.Count -gt 0) {
    # Pick the lexicographically latest (e.g. 2026-07-29 > 2026-07-15)
    $best = ($matches | ForEach-Object { $_.Groups[1].Value } | Sort-Object | Select-Object -Last 1)
    Write-Output $best
}
