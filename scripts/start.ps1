# Start the PostgreSQL container (created and filled at the first start) and wait until it is ready.
Set-Location (Join-Path $PSScriptRoot "..")
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
docker compose up -d
Write-Host "Waiting for PostgreSQL..."
for ($i = 0; $i -lt 60; $i++) {
  $n = docker compose exec -T postgres psql -U postgres -d shop -tAc "SELECT count(*) FROM orders" 2>$null
  if ($LASTEXITCODE -eq 0) { Write-Host "Ready: shop.orders has $($n.Trim()) rows."; exit 0 }
  Start-Sleep -Seconds 2
}
Write-Error "PostgreSQL is not ready after 2 minutes: docker compose logs postgres"
exit 1
