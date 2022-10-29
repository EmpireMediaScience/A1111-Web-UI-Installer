Add-Type -AssemblyName PresentationFramework

try {
    $installPath = AI_GetMsiProperty APPDIR 
    Write-Output "The path is", $installPath
    if (Test-Path $installPath) {
        Remove-Item $installPath -Force -Recurse
    }    
    New-Item -path $installPath -Force -ItemType Directory -Verbose
    Set-Location $installPath 
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
}
catch {
    [system.windows.messagebox]::Show("The WebUI couldn't be cloned from the source URL, something is wrong, contact the support", '  Error', 'OK', 'Error')
    return
    exit
}

