param(
    [string]$BaseUrl = "http://127.0.0.1:8080",
    [string]$Model = "qwen3-8b-q8"
)

$ErrorActionPreference = "Stop"

$uri = "$BaseUrl/v1/chat/completions"
$body = @{
    model = $Model
    messages = @(
        @{ role = "system"; content = "You are a concise and accurate assistant." },
        @{ role = "user"; content = "Introduce yourself in one sentence." }
    )
    temperature = 0.7
    stream = $false
} | ConvertTo-Json -Depth 8

try {
    $resp = Invoke-RestMethod -Method Post -Uri $uri -ContentType "application/json" -Body $body
    if ($null -eq $resp.choices -or $resp.choices.Count -eq 0) {
        Write-Error "Request succeeded but response is empty. Check server logs."
    }
    Write-Host "Request succeeded. Model reply:"
    Write-Host $resp.choices[0].message.content
}
catch {
    Write-Error ("Request failed: " + $_.Exception.Message)
}
