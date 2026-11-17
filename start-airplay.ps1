# start-airplay.ps1 - Auto-start AirPlay2 on JBL Link Music after reboot (run from Windows PC)
param(
    [string]$IP = "192.168.1.83",
    [string]$KeyPath = "$env:USERPROFILE\jbl_user_ed25519"
)
$ErrorActionPreference = "Stop"

Write-Host "Connecting ADB..."
adb connect "$IP`:5555" | Out-Null
Start-Sleep -Seconds 2

Write-Host "Starting SSH service..."
adb -s "$IP`:5555" shell "sh /data/jbl-ssh/service.sh start" | Out-Null
Start-Sleep -Seconds 2

Write-Host "Starting AirPlay2 stack..."
ssh -i "$KeyPath" -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL "root@$IP" "sh /data/start-all.sh"

Write-Host "Done. AirPlay2 should be running as 'JBL Link Music'."
