param([string]$BaseUrl = 'http://127.0.0.1:7125', [string]$ReportPath = 'review/evidence/final_assets.json')
# Run with the app already running. Checks every bundled image, not only the logo.
$ErrorActionPreference = 'Stop'
$reviewRepo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$reviewCases = @(Get-ChildItem -LiteralPath (Join-Path $reviewRepo 'Project_PPeek1ng\www\img') -File | ForEach-Object {
  $reviewUrl = $BaseUrl.TrimEnd('/') + '/img/' + [uri]::EscapeDataString($_.Name)
  try {
    $reviewResponse = Invoke-WebRequest -Uri $reviewUrl -Method Head
    $reviewType = [string]$reviewResponse.Headers['Content-Type']
    [pscustomobject]@{file=$_.Name; status=[int]$reviewResponse.StatusCode; content_type=$reviewType;
      passed=($reviewResponse.StatusCode -eq 200 -and $reviewType.StartsWith('image/'))}
  } catch { [pscustomobject]@{file=$_.Name; passed=$false; error=$_.Exception.Message} }
})
$reviewReport = [ordered]@{date=(Get-Date -Format o); total=$reviewCases.Count;
  passed=@($reviewCases | Where-Object passed).Count; cases=$reviewCases;
  source_sha256=@(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $reviewRepo 'Start-Shiny.R'),(Join-Path $reviewRepo 'Project_PPeek1ng\app.R'))}
$reviewReport | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $reviewRepo $ReportPath) -Encoding utf8
Write-Output "$($reviewReport.passed)/$($reviewReport.total) bundled images served correctly."
if ($reviewReport.passed -ne $reviewReport.total) { throw 'Image asset regression failed.' }
