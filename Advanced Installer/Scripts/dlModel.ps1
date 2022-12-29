Add-Type -AssemblyName PresentationFramework
try {
    $installPath = AI_GetMsiProperty APPDIR
    $modelsPath = "$installPath\models"
    if (!(Test-Path $modelsPath)) {
        New-Item -ItemType Directory $modelsPath -Force
    }
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://anga.tv/ems/model.ckpt", "$modelsPath\SD15NewVAEpruned.ckpt")
}
catch {
    [system.windows.messagebox]::Show("Something went wrong with the download", '  Error', 'OK', 'Error')
    return
    exit
}
