Add-Type -AssemblyName PresentationFramework

try {
    $installPath = AI_GetMsiProperty APPDIR
    <#     $installPath = "D:\Documents\A1111's Web UI Autoinstaller"     #>
    Write-Output "The path is $installPath" 
    $webuiPath = "$installPath\stable-diffusion-webui"
    if (Test-Path $webuiPath) {
        Remove-Item $webuiPath -Force -Recurse
    }    
    Set-Location $installPath 
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
}
catch {
    $err = $_
    Write-Host $_
    [system.windows.messagebox]::Show("The WebUI couldn't be cloned from the source URL, something is wrong, contact the support`n`n$err", '  Error', 'OK', 'Error')
    return
    exit
}

