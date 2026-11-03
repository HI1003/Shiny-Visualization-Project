param(
  [string]$RscriptPath = 'C:\Program Files\R\R-4.6.1\bin\x64\Rscript.exe',
  [string]$PythonPath = 'C:\Program Files\Inkscape\bin\python.exe',
  [string]$ReportPrefix = 'final'
)
$ErrorActionPreference = 'Stop'
$reviewRepo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if (-not (Test-Path -LiteralPath $RscriptPath)) { $RscriptPath = (Get-Command Rscript -ErrorAction Stop).Source }
if (-not (Test-Path -LiteralPath $PythonPath)) { $PythonPath = (Get-Command python -ErrorAction Stop).Source }
Push-Location -LiteralPath $reviewRepo
try {
  New-Item -ItemType Directory -Force -Path '.local' | Out-Null
  & $RscriptPath --vanilla review/scripts/test_r1_04.R "review/evidence/${ReportPrefix}_r1_04_ui.json"
  if ($LASTEXITCODE -ne 0) { throw 'Joint question regression failed.' }
  & $PythonPath review/scripts/test_r1_04_math.py .local/r1_04_bank.json "review/evidence/${ReportPrefix}_r1_04_math.json"
  if ($LASTEXITCODE -ne 0) { throw 'Exact joint probability checks failed.' }
  & $RscriptPath --vanilla review/scripts/test_r1_05.R "review/evidence/${ReportPrefix}_r1_05.json"
  if ($LASTEXITCODE -ne 0) { throw 'Conditional PMF regression failed.' }
  & $RscriptPath --vanilla review/scripts/test_r1_06.R "review/evidence/${ReportPrefix}_r1_06.json"
  if ($LASTEXITCODE -ne 0) { throw 'PMF input and synchronization regression failed.' }
  & $RscriptPath --vanilla review/scripts/test_remaining.R "review/evidence/${ReportPrefix}_remaining.json"
  if ($LASTEXITCODE -ne 0) { throw 'Remaining module regression failed.' }
  & $RscriptPath --vanilla review/scripts/test_past_exam_bank.R "review/evidence/${ReportPrefix}_past_exams.json"
  if ($LASTEXITCODE -ne 0) { throw 'Verified local past-exam checks failed.' }
  & $RscriptPath --vanilla review/scripts/test_number_display.R "review/evidence/${ReportPrefix}_precision.json"
  if ($LASTEXITCODE -ne 0) { throw 'Number display and full-precision preservation checks failed.' }
  Write-Output "All regression groups passed; results saved in review/evidence/${ReportPrefix}_*.json."
} finally { Pop-Location }
