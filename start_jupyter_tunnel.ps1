param(
    [string]$SshHost = "ubuntu@118.89.41.23",
    [int]$LocalPort = 18888,
    [string]$RemoteHost = "127.0.0.1",
    [int]$RemotePort = 8888
)

$ErrorActionPreference = "Stop"

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

if (-not (Test-CommandExists "ssh")) {
    Write-Host "OpenSSH client was not found. Install it from Windows Optional Features, then run this script again." -ForegroundColor Red
    exit 1
}

$listening = Get-NetTCPConnection -LocalAddress "127.0.0.1" -LocalPort $LocalPort -State Listen -ErrorAction SilentlyContinue
if ($listening) {
    Write-Host "Local port $LocalPort is already listening. If VS Code can connect, you may already have a tunnel open." -ForegroundColor Yellow
    Write-Host "VS Code Jupyter URL: http://127.0.0.1:$LocalPort/?token="
    exit 0
}

Write-Host "Starting SSH tunnel..." -ForegroundColor Cyan
Write-Host "  local:  127.0.0.1:$LocalPort"
Write-Host "  remote: ${RemoteHost}:${RemotePort} via $SshHost"
Write-Host ""
Write-Host "Keep this window open while using VS Code Jupyter." -ForegroundColor Yellow
Write-Host "VS Code Jupyter URL: http://127.0.0.1:$LocalPort/?token="
Write-Host ""

ssh -N -L "$LocalPort`:$RemoteHost`:$RemotePort" $SshHost
