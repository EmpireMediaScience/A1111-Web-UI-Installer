Add-Type -AssemblyName PresentationFramework
try {
    $installPath = AI_GetMsiProperty APPDIR 
    $modelsPath = "$installPath\stable-diffusion-webui\models\Stable-diffusion"

    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://drive.yerf.org/wl/?id=EBfTrmcCCUAGaQBXVIj5lJmEhjoP1tgl&mode=grid&download=1", "$modelsPath\model.ckpt")
}
catch {
    [system.windows.messagebox]::Show("Something went wrong with the download", '  Error', 'OK', 'Error')
    return
    exit
}
[system.windows.messagebox]::Show("The Model was successfuly downloaded, have fun", '  Success', 'OK', 'Info')
