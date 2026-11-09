# Start again from zero: remove the container and its data, then create them again.
Set-Location (Join-Path $PSScriptRoot "..")
docker compose down -v
& (Join-Path $PSScriptRoot "start.ps1")
