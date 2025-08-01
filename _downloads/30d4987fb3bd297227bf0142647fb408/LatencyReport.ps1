Param(
    [Datetime]$stop_time,
    [String]$NetId,
    [Int]$wait_time
)


if (-! $NetId){
    $NetId = "127.0.0.1.1.1"
}

if (-! $wait_time){
    $wait_time = 0
}


$now = Get-Date
if (-! $stop_time){
    $stop_time = $now.AddSeconds(5)
}

$file_suffix = $stop_time.ToString("yyMMddHHmmss")

while ($now -lt $stop_time){
    $row = Get-RTimeLatency -NetId ${NetId} | Select-Object `
        @{Name="Time"; Expression={$now.ToString('yyyy/MM/dd HH:mm:ss.fff')}},
        @{Name="Core ID"; Expression="CoreId"},
        @{Name="Latency"; Expression="Latency"},
        @{Name="Max Latency"; Expression="MaxLatency"}
    $row | Export-Csv -Path ".\latency_${NetId}_${file_suffix}.csv" -NoTypeInformation -Append
    $row | Select-Object
    if ($wait_time -gt 0){
        Start-Sleep -Millisecond $wait_time
    }
    $now = Get-Date
}

echo("Recording finished")