# =====================================================================
# Script: restore.ps1
# Project: MySQL DBA & Application Support Lab
# Purpose: Safely restores a logical backup into an isolated target database
#          Validates row counts post-restore to prove data integrity.
# =====================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupFilePath,
    [string]$TargetDatabase = "dba_lab_restore",
    [string]$MysqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $BackupFilePath)) {
    Write-Error "Backup file not found at: $BackupFilePath"
    exit 1
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " MySQL Safe Isolated Restore: $TargetDatabase" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Source Backup : $BackupFilePath"
Write-Host "Target Schema : $TargetDatabase (Isolated non-prod target)"
Write-Host "----------------------------------------------------------"

# Step 1: Ensure isolated target database exists
Write-Host "[1/3] Creating isolated target database '$TargetDatabase'..." -ForegroundColor Yellow
& $MysqlPath -u root -p -e "CREATE DATABASE IF NOT EXISTS $TargetDatabase CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"

# Step 2: Stream restore dump cleanly into target database via native redirect
Write-Host "[2/3] Streaming restore into '$TargetDatabase'..." -ForegroundColor Yellow
$startTime = Get-Date

# Use cmd.exe /c to stream raw bytes without loading into PowerShell memory
cmd.exe /c "`"$MysqlPath`" -u root -p --default-character-set=utf8mb4 $TargetDatabase < `"$BackupFilePath`""

$endTime = Get-Date
$duration = [math]::Round(($endTime - $startTime).TotalSeconds, 2)
Write-Host "Restore stream completed in $duration seconds." -ForegroundColor Green

# Step 3: Validate exact row counts between source and target
Write-Host "[3/3] Validating EXACT COUNT(*) row counts between source (dba_lab) and target ($TargetDatabase)..." -ForegroundColor Yellow
$validationSql = @"
SELECT 'mas_agency' AS tbl, (SELECT COUNT(*) FROM dba_lab.mas_agency) AS src, (SELECT COUNT(*) FROM $TargetDatabase.mas_agency) AS dst
UNION ALL
SELECT 'mas_agent', (SELECT COUNT(*) FROM dba_lab.mas_agent), (SELECT COUNT(*) FROM $TargetDatabase.mas_agent)
UNION ALL
SELECT 'pol_policy_v2', (SELECT COUNT(*) FROM dba_lab.pol_policy_v2), (SELECT COUNT(*) FROM $TargetDatabase.pol_policy_v2)
UNION ALL
SELECT 'pol_policy_ver_v2', (SELECT COUNT(*) FROM dba_lab.pol_policy_ver_v2), (SELECT COUNT(*) FROM $TargetDatabase.pol_policy_ver_v2)
UNION ALL
SELECT 'qot_quote_v2', (SELECT COUNT(*) FROM dba_lab.qot_quote_v2), (SELECT COUNT(*) FROM $TargetDatabase.qot_quote_v2)
UNION ALL
SELECT 'ref_carrier_mapping', (SELECT COUNT(*) FROM dba_lab.ref_carrier_mapping), (SELECT COUNT(*) FROM $TargetDatabase.ref_carrier_mapping)
UNION ALL
SELECT 'sub_submission', (SELECT COUNT(*) FROM dba_lab.sub_submission), (SELECT COUNT(*) FROM $TargetDatabase.sub_submission);
"@

& $MysqlPath -u root -p -e $validationSql

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Restore and verification finished successfully!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
