# autostart-daemon.ps1 - PC-side daemon that auto-starts AirPlay2 after device reboot (Windows)
# Usage: powershell -File autostart-daemon.ps1 [-IP 192.168.1.83] [-KeyPath ...] [-Interval 10]
param(
    [string]$IP = "192.168.1.83",
    [string]$KeyPath = "$env:USERPROFILE\jbl_user_ed25519",
    [int]$Interval = 10
)
$ErrorActionPreference = "SilentlyContinue"
Write-Host "Watching for $IP (poll every ${Interval}s). Press Ctrl+C to stop."
while ($true) {
    $ping = Test-Connection -ComputerName $IP -Count 1 -Quiet -TimeoutSeconds 2
    if ($ping) {
        adb connect "$IP`:5555" | Out-Null
        Start-Sleep -Seconds 2
        $adbOk = (adb -s "$IP`:5555" shell "echo ok" 2>$null) -match "ok"
        if ($adbOk) {
            $sshOk = (ssh -i "$KeyPath" -p 2222 -o ConnectTimeout=3 -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL "root@$IP" "echo ok" 2>$null) -match "ok"
            if (-not $sshOk) {
                adb -s "$IP`:5555" shell "sh /data/jbl-ssh/service.sh start" | Out-Null
                Start-Sleep -Seconds 2
                $sshOk = (ssh -i "$KeyPath" -p 2222 -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL "root@$IP" "echo ok" 2>$null) -match "ok"
            }
            if ($sshOk) {
                $running = (ssh -i "$KeyPath" -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL "root@$IP" "pidof shairport-sync" 2>$null)
                if (-not $running) {
                    Write-Host "[$(Get-Date)] Device online, starting AirPlay2..."
                    ssh -i "$KeyPath" -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL "root@$IP" "sh /data/start-all.sh" | Out-Null
                    Write-Host "[$(Get-Date)] AirPlay2 started."
                }
            }
        }
    }
    Start-Sleep -Seconds $Interval
}
