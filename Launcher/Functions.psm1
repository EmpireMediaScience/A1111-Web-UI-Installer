. "$PSScriptRoot\shared.ps1"

#Startup fonctions
#-----------------------------
function Search-RegForPyPath {
    $regPaths = @("hkcu:\Software\Python\PythonCore\3.10\InstallPath", "hklm:\Software\Python\PythonCore\3.10\InstallPath")

    foreach ($path in $regPaths) {
        $pyCore = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
        if ($pyCore) {
            $pyPath = $pyCore.'(default)'
            $pyVersion = (Get-Command -Name "$pyPath\python.exe").Version
            logger.info "Python $pyVersion found in registry:" "$pyPath"
            if ($pyVersion -notlike "3.10.6150.1013") {
                $Exprompt = [system.windows.messagebox]::Show("You've installed Python 3.10 ($pyVersion) previously, but it is not the right version. This could lead to errors.`n`nTo fix this, uninstall all the versions of Python 3.10 from your system and restart the launcher`n`nDo you want to continue anyway ?", "Python $pyVersion not recommended", 'YesNo')
                logger.warn "This is not the recommended version of Python and will probably cause errors"
                if ($Exprompt -eq "No") {
                    exit
                }
            }
            return $pyPath
        }
    }
    return ""
}
function Install-py {
    $Global:pyPath = Search-RegForPyPath
    if ($Global:pyPath -eq "") {
        logger.web -Type "download" -Object "Python 3.10 not found, downloading & installing, please be patient"
        Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.10.6/python-3.10.6-amd64.exe" -OutFile "$tempFolder\python.exe"
        ."$tempFolder\python.exe" /quiet InstallAllUsers=0 PrependPath=1
        logger.success "Done"
        $Global:pyPath = Search-RegForPyPath
    }
    logger.info "Clearing PATH of any mention of Python"
    $env:Path = [System.String]::Join(";", $($env:Path.split(';') | Where-Object { $_ -notmatch "python" }))
    logger.action "Adding python 3.10 to path" -success
    $env:Path += ";$Global:pyPath"
    logger.success
    return
}
function Install-git {
    $gitInPath = Get-Command git -ErrorAction SilentlyContinue
    if ($gitInPath) {
        $Global:gitPath = $gitInPath.Source
        logger.info "Git found and already in PATH:" "$($gitInPath.Source)"
        return
    }
    else {
        if (!(Test-Path "$gitPath\bin\git.exe")) {
            logger.web -Type "download" -Object "Git not found, downloading & installing, please be patient"
            Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.38.1.windows.1/Git-2.38.1-64-bit.exe" -OutFile "$tempFolder\git.exe"
            ."$tempFolder\git.exe" /VERYSILENT /NORESTART
            logger.success
        }
        else {
            logger.info "Git found" "$("$env:ProgramFiles\Git")"
        }
        if (!(Get-Command git -ErrorAction SilentlyContinue)) {
            logger.action "Git not found in PATH, adding it" -success
            $env:Path += ";$gitPath\bin"
            logger.success
            return
        }
        else {
            logger.info "Git is in PATH"
        }
    }
}
function Install-WebUI {
    if (!(Test-Path $webuiPath)) {
        logger.web -Type "download" -Object "Cloning Automatic1111 SD WebUI git"
        git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui $webuiPath
        logger.success "Done"
        return
    }
    logger.info "Automatic1111 SD WebUI found:" "$webuiPath"
}
function Reset-WebUI {
    $Exprompt = [system.windows.messagebox]::Show("This will entirely wipe the WebUI folder and reclone it from github, make sure you have all your important data & models backed up.`n`n Are you sure you want to reset the WebUI folder ?", 'Careful There', 'YesNo', 'Warning')
    if ($Exprompt -eq "Yes") {
        logger.action "Removing the Webui Folder" -success
        Remove-Item $webuiPath -Recurse -Force
        logger.success
        Install-WebUI 
    }
}
function Import-BaseModel {
    $ckptDirSetting = $settings | Where-Object { $_.arg -eq "ckpt-dir" }
    if (($ckptDirSetting.enabled -eq $false) -and !(Get-ChildItem $modelsPath | Where-Object { $_.extension -ne ".txt" })) {
        $Exprompt = [system.windows.messagebox]::Show("No model was found on your installation, do you want to download the Stable Diffusion 1.5 base model ?`n`nIf you don't know what that is, you probably want to click Yes`n`nThis will take a while so be patient", 'Install SD 1.5 Model ?', 'YesNo')
        if ($Exprompt -eq "Yes") {
            $url = "https://anga.tv/ems/model.ckpt"
            $destination = "$modelsPath\SD15NewVAEpruned.ckpt"
            $request = [System.Net.HttpWebRequest]::Create($url)
            $response = $request.GetResponse()
            $fileSize = [int]$response.ContentLength
            Start-Job -ScriptBlock {
                param($url, $destination)
                $WebClient = New-Object System.Net.WebClient
                $WebClient.DownloadFile($url, $destination)
                Write-Host "Download complete"
            } -ArgumentList $url, $destination | Out-Null

            while (!(Test-Path $destination)) {
                logger.info "Waiting for file to be created..."
                Start-Sleep -Seconds 1
            }
            $timePassed = 0.1
            while ((Get-Item $destination).Length -lt $fileSize) {              
                $downloadSize = (Get-Item $destination).Length
                $ratio = [Math]::Ceiling($downloadSize / $fileSize * 100)
                $dlRate = $ratio / $timePassed
                $remainingPercent = (100 - $ratio)
                $remainingTime = [Math]::Floor($remainingPercent / $dlRate)
                logger.dlprogress "Downloading model: $ratio % | ~ $remainingTime s remaining  "
                Start-Sleep -Seconds 1
                $timePassed += 1
            }
            logger.success
        }
    }
    else {
        logger.info "One or more checkpoint models were found"
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
    logger.action "Updating Settings File" -success
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
        logger.success "Done"
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
            logger.success "Done"
            return
        }
        logger.info "There is no extension in the extensions folder"
    }
}
function Clear-Outputs {
    $Exprompt = [system.windows.messagebox]::Show("All previously generated images will be deleted, are you sure ?`n`nClick 'No' to not delete any image this time`n`nUncheck 'Clear Generated Images' in the launcher to disable this function", 'Warning', 'YesNo', 'Warning')
    if ($Exprompt -eq "Yes") {
        if ($webuiConfig -ne "" -and $webUIConfig.outdir_samples -ne "") {
            logger.action "Clearing all outputs in custom output directories ($($webUIConfig.outdir_samples))"
            Get-ChildItem $webUIConfig.outdir_samples -Force -Recurse -File | Where-Object { $_.Extension -eq ".png" -or $_.Extension -eq ".jpg" } | Remove-Item -Force
        }
        else {
            if ($outputsPath) {
                logger.action "Clearing all outputs in default output directories"
                Get-ChildItem $outputsPath -Force -Recurse -File | Where-Object { $_.Extension -eq ".png" -or $_.Extension -eq ".jpg" } | Remove-Item -Force
            }
        }
        logger.success "Done"
    }
}