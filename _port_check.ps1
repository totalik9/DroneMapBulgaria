# Check whether 127.0.0.1:8765 is currently bound
try {
    $client = New-Object System.Net.Sockets.TcpClient
    $client.Connect('127.0.0.1', 8765)
    $client.Close()
    Write-Output 'BUSY'
} catch {
    Write-Output 'FREE'
}
