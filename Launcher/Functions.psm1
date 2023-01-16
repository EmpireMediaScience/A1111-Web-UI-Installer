. "$PSScriptRoot\shared.ps1"
Import-Module "$PSScriptRoot\logger.psm1" -Force -Global -Prefix "logger."

#Startup fonctions
#-----------------------------
function Search-RegForPyPath {
    $pyCore = Get-ItemProperty -path "hkcu:\Software\Python\PythonCore\3.10\InstallPath" -ErrorAction SilentlyContinue
    if ($pyCore) {
        $pyPath = $pyCore.ExecutablePath
        logger.info "Python 3.10 path found : $pyPath"
        return $pyPath
    }
    else {
        $pyCoreLM = Get-ItemProperty -path "hklm:\Software\Python\PythonCore\3.10\InstallPath" -ErrorAction SilentlyContinue
        if ($pyCoreLM) {
            $pyPath = $pyCoreLM.ExecutablePath
            logger.info "Python 3.10 path found : $pyPath"
            return $pyPath
        }
        else {
            return ""
        }
    }
}
function Install-py {
    $Global:pyPath = Search-RegForPyPath
    if ($Global:pyPath -eq "") {
        logger.web -Type "download" -Object "Python 3.10 not found, downloading & installing, please be patient"
        Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.10.6/python-3.10.6-amd64.exe" -OutFile "$tempFolder\python.exe"
        ."$tempFolder\python.exe" /quiet InstallAllUsers=0 PrependPath=1
        logger.success
        $Global:pyPath = Search-RegForPyPath
    }
    if (!(Get-Command python -ErrorAction SilentlyContinue)) {
        logger.action "Python not found in PATH, adding it"
        $env:Path += ";$Global:pyPath\bin"
        logger.success
        return
    }
    else {
        logger.info "Python is in PATH"
    }
}
function Install-git {
    if (!(Test-Path "$gitPath\bin\git.exe")) {
        logger.web -Type "download" -Object "Git not found, downloading & installing, please be patient"
        Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.38.1.windows.1/Git-2.38.1-64-bit.exe" -OutFile "$tempFolder\git.exe"
        ."$tempFolder\git.exe" /VERYSILENT /NORESTART
        logger.success
    }
    else {
        logger.info "Git found at $("$env:ProgramFiles\Git")"
    }
    if (!(Get-Command git -ErrorAction SilentlyContinue)) {
        logger.action "Git not found in PATH, adding it"
        $env:Path += ";$gitPath\bin"
        logger.success
        return
    }
    else {
        logger.info "Git is in PATH"
    }
    
}
function Install-WebUI {
    if (!(Test-Path $webuiPath)) {
        logger.web -Type "download" -Object "Automatic1111 SD WebUI was not found, cloning git"
        git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui $webuiPath
        logger.success
        return
    }
    logger.info "Automatic1111 SD WebUI found at $webuiPath"
}
function Import-BaseModel {
    $ckptDirSetting = $settings | Where-Object { $_.arg -eq "ckpt-dir" }
    if (($ckptDirSetting.enabled -eq $false) -and !(Get-ChildItem $modelsPath | Where-Object { $_.extension -ne ".txt" })) {
        $Exprompt = [system.windows.messagebox]::Show("No model was found on your installation, do you want to download the Stable Diffusion 1.5 base model ?`n`nIf you don't know what that is, you probably want to click Yes`n`nThis will take a while so be patient", 'Confirmation', 'YesNo')
        if ($Exprompt -eq "Yes") {
            logger.action "Downloading Base Model, this can take a while" 
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile("https://anga.tv/ems/model.ckpt", "$modelsPath\SD15NewVAEpruned.ckpt")
            logger.success
        }
    }
}
function Get-Version {
    $result = @{
        Long  = ""
        Short = ""
    }
    $softInfo = Get-ItemProperty -LiteralPath 'hkcu:\Software\Empire Media Science\A1111 Web UI Autoinstaller'
    if ($softInfo) {
        logger.info "Launcher Version $($softInfo.Version)"
        $short = $softInfo.Version.Split(".")
        $result.Long = $softInfo.Version
        $result.Short = $short[0] + "." + $short[1]
    }
    else {
        logger.warn "Version Not Found"
        $result.Long = "Version Not Found"
        $result.Short = "2023.01"
    }
    return $result
}
function Get-GPUInfo {
    $adapterMemory = (Get-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0*" -Name "HardwareInformation.AdapterString", "HardwareInformation.qwMemorySize" -Exclude PSPath -ErrorAction SilentlyContinue)

    $adapters = @()

    foreach ($adapter in $adapterMemory) {
        if ($adapter."HardwareInformation.AdapterString" -ilike "NVIDIA*") {
            $adapterObject = @{
                Model = $adapter."HardwareInformation.AdapterString"
                VRAM  = [math]::round($adapter."HardwareInformation.qwMemorySize" / 1GB)
            }
            $adapters += $adapterObject
        }
    }
    switch ($adapters.Count) {
        { $_ -gt 0 } { return @($adapters)[0] }
        { $_ -eq 0 } { return $false }
    }
}
function Get-WebUICommitHash {
    $hash = Get-Content $hashPath
    if ($hash) { return $hash }
}

#Settings related functions
#-----------------------------
function Write-Settings($settings) {
    logger.action "Updating Settings File"
    $settings | ConvertTo-Json -Depth 100 | Out-File $settingsPath
    logger.success
}
function New-Settings ($oldsettings) {   
    $defs = Import-Defs
    $newSettings = @()
    foreach ($def in $defs) { 
        $newSettings += @{ 
            arg     = $def.arg
            enabled = $false
            value   = "" 
        }
    }
    if ($oldsettings) {
        foreach ($oldSetting in $oldsettings) {
            $newSetting = $newSettings | Where-Object { $_.arg -eq $oldSetting.arg }
            if ($newSetting) {
                $newSetting.arg = $oldSetting.arg
                $newSetting.enabled = $oldSetting.enabled
                $newSetting.value = $oldSetting.value
            }
        }
    }
    Write-Settings $newSettings
    return $newSettings
}
function Restore-Settings {    
    $oldsettings = ""
    if (Test-Path $settingsPath) {
        $settingsfile = Get-Content $settingsPath
        logger.info "Settings file found, loading"
        $oldsettings = $settingsfile | ConvertFrom-Json
    }
    else {
        logger.info "Settings not file found, creating"
    }
    $settings = New-Settings $oldsettings
    return $settings
}
function Update-Settings($param, $settings) {
    $setting = $settings | Where-Object { $_.arg -ilike $param.name }
    if ($param.Tag -eq "path") {
        if ($setting.arg -ilike "*dir") {
            $path = Select-Folder -InitialDirectory $setting.value
        }
        else {
            $path = Select-File -InitialDirectory $setting.value
        }
        if ($path) {
            logger.info "$($param.text) updated to $path"
            $setting.value = $path
            $setting.enabled = $true
        }
    }
    elseif ($param.Tag -eq "string") {
        logger.info "Additional Args updated"
        $setting.value = $param.text
    }
    else {
        logger.info "$($param.text) updated to $($param.Checked)"
        $setting.enabled = $param.Checked
    }
    Write-Settings $settings
        
}
function Import-Defs {
    $defs = Get-Content .\definitions.json | ConvertFrom-Json
    return $defs
}
function Convert-SettingsToArguments ($settings) {
    $string = ""
    foreach ($setting in $settings) {
        if ($setting.arg -ilike "git*" ) {
            # Not Command Line Arg Related
        }
        elseif ($setting.arg -eq "Add" ) {
            $string += "$($setting.value) "
        }
        else {
            if ($setting.enabled -eq $true) {
                if ($setting.value -eq "") {
                    $string += "--$($setting.arg) "
                }
                else {
                    $string += "--$($setting.arg) '$($setting.value )' "
                }
            }
        }
    }
    if ($string -ne " ") {
        logger.info "Arguments are now:", $string
    }
    else {
        logger.info "No arguments set"
    }
    return $string
}
function Convert-BatToGitOptions ($batFile) {
    $GitOptions = @( 
        @{
            arg     = "git-Ext"
            enabled = $false
        },
        @{
            arg     = "git-UI"
            enabled = $false
        }
    )
    if ($batFile -notcontains "::") {
        logger.info "No git options found"
    }
    else {
        if ($batFile -contains "Update Extensions") {
            $GitOptions[0].enabled = $true
        }
        if ($batFile -contains "Update WebUI") {
            $GitOptions[1].enabled = $true
        }
    }
    return $GitOptions
}


#UI related functions
#-----------------------------
function Select-Folder ([string]$InitialDirectory) {
    $app = New-Object -ComObject Shell.Application
    $folder = $app.BrowseForFolder(0, "Please select a folder", 0, "")
        
    if ($folder) { return $folder.Self.Path } else { return '' }
}
function Select-File([string]$InitialDirectory) { 
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.InitialDirectory = $webuiPath
    $dialog.Title = "Please Select a File"
    If ($dialog.ShowDialog() -eq "Cancel") {
        return ''
    }   
    return $dialog.FileName 
}


#General Settings functions
#-----------------------------
function Update-WebUI ($enabled) {
    if ($enabled) {
        logger.web -Type "update" -Object "Updating Webui"
        Set-Location $webuiPath
        git pull origin
        logger.success
    }
}
function Update-Extensions ($enabled) {
    if ($enabled) {
        Set-Location $extPath
        $exts = Get-ChildItem $extPath -Directory
        if ($exts) {
            foreach ($ext in $exts) {         
                logger.web -Type "update" -Object "Updating Extension: $ext"
                Set-Location $ext.Fullname
                git pull origin 
            }
            logger.success
            return
        }
        logger.warn "No extension found in the extensions folder"
    }
}
function Clear-Outputs {
    $Exprompt = [system.windows.messagebox]::Show("All previously generated images will be deleted, are you sure ?`n`nClick 'No' to not delete any image this time`n`nUncheck 'Clear Generated Images' in the launcher to disable it", 'Warning', 'YesNo', 'Warning')
    if ($Exprompt -eq "Yes") {
        logger.action "Clearing all outputs in default output directories" 
        if ($outputsPath) {
            Get-ChildItem $outputsPath -Force -Recurse -File -Filter *.png | Remove-Item -Force
            Get-ChildItem $outputsPath -Force -Recurse -File -Filter *.jpg | Remove-Item -Force
        }
        logger.success
    }
}