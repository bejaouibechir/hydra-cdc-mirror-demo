# Run one of the db/*.sql scripts in the container:  .\scripts\sql.ps1 changes
param([Parameter(Mandatory = $true)][string]$Name)
Set-Location (Join-Path $PSScriptRoot "..")
Get-Content "db/$Name.sql" -Raw | docker compose exec -T postgres psql -U postgres -d postgres -v ON_ERROR_STOP=1 -q
