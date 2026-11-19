# =====================================================================
# Script: backup.ps1
# Project: MySQL DBA & Application Support Lab
# Purpose: Generates a consistent, non-blocking logical backup using mysqldump
# Target: dba_lab -> backups/dba_lab_backup_YYYYMMDD_HHMMSS.sql
# =====================================================================

param(
    [string]$Database = "dba_lab",
    [string]$BackupDir = "E:\project\MySQL DBA\backups",
    [string]$MysqlDumpPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = Join-Path $BackupDir "${Database}_backup_${timestamp}.sql"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " MySQL Consistent Logical Backup: $Database" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Timestamp   : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Target File : $backupFile"
Write-Host "Flags       : --single-transaction --quick --routines --triggers --result-file"
Write-Host "----------------------------------------------------------"

$startTime = Get-Date

# Use --result-file to guarantee pure utf8mb4 encoding without PowerShell UTF-16 conversion
& $MysqlDumpPath `
    -u root -p `
    --single-transaction `
    --quick `
    --routines `
    --triggers `
    --default-character-set=utf8mb4 `
    --result-file="$backupFile" `
    $Database

$endTime = Get-Date
$duration = [math]::Round(($endTime - $startTime).TotalSeconds, 2)
$fileSizeMB = [math]::Round((Get-Item $backupFile).Length / 1MB, 2)

Write-Host "----------------------------------------------------------" -ForegroundColor Green
Write-Host "Backup completed successfully!" -ForegroundColor Green
Write-Host "Elapsed Time : $duration seconds" -ForegroundColor Green
Write-Host "Backup Size  : $fileSizeMB MB" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
