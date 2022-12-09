Add-Type -AssemblyName PresentationFramework

try {
    $installPath = AI_GetMsiProperty APPDIR
    if (Test-Path $installPath) {
    }
    else {
        Write-Host "Creating $installPath"
        New-Item -ItemType Directory -Path $installPath
    }
    Write-Output "The path is $installPath" 
    $webuiPath = "$installPath\stable-diffusion-webui"
    Set-Location $installPath
    if (Test-Path $webuiPath) {        
        Remove-Item $webuiPath -Force -Recurse  
    }
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
   
}
catch {
    $err = $_
    Write-Host $_
    [system.windows.messagebox]::Show("The WebUI couldn't be cloned from the source URL, something is wrong, contact the support`n`n$err", '  Error', 'OK', 'Error')
    return
    exit
}

