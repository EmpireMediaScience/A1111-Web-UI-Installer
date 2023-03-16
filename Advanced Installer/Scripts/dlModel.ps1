Add-Type -AssemblyName PresentationFramework

try {
    $installPath = AI_GetMsiProperty APPDIR
    $modelsPath = Join-Path $installPath "models"
    if (-not (Test-Path $modelsPath)) {
        New-Item -ItemType Directory $modelsPath -Force
    }
    $WebClient = New-Object System.Net.WebClient
    $modelUrl = "https://anga.tv/ems/model.ckpt"
    $modelLocalPath = Join-Path $modelsPath "SD15NewVAEpruned.ckpt"
    $WebClient.DownloadFile($modelUrl, $modelLocalPath)
}
catch {
    [System.Windows.MessageBox]::Show("Something went wrong with the download", '  Error', 'OK', 'Error')
    return
    exit
}
