Add-Type -AssemblyName PresentationFramework

try {
    $installPath = AI_GetMsiProperty APPDIR
    if (-not (Test-Path $installPath)) {
        Write-Host "Creating $installPath"
        New-Item -ItemType Directory -Path $installPath
    }
    Write-Output "The path is $installPath" 
    $webuiPath = Join-Path $installPath "stable-diffusion-webui"
    Set-Location $installPath
    if (Test-Path $webuiPath) {        
        Remove-Item $webuiPath -Force -Recurse  
    }  
}
catch {
    $err = $_
    Write-Host $_
    [System.Windows.MessageBox]::Show("The previous WebUI couldn't be deleted, something is wrong, contact the support`n`n$err", '  Error', 'OK', 'Error')
    return
    exit
}
