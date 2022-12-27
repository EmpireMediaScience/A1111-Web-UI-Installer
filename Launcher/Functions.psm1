. "$PSScriptRoot\shared.ps1"
Import-Module "$PSScriptRoot\logger.psm1" -Force -Global -Prefix "logger."

# General Utilities
function Get-Version {
    logger.action "Fetching Launcher Version"
    $result = @{
        Long  = ""
        Short = ""
    }
    $softInfo = Get-ItemProperty -LiteralPath 'hkcu:\Software\Empire Media Science\A1111 Web UI Autoinstaller'
    if ($softInfo) {
        logger.info "Version $($softInfo.Version) Found"
        $short = $softInfo.Version.Split(".")
        $result.Long = $softInfo.Version
        $result.Short = $short[0] + "." + $short[1]
    }
    else {
        logger.info "Version Not Found"
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
function Write-Settings($settings) {
    logger.action "Updating Settings File"
    $settings | ConvertTo-Json -Depth 100 | Out-File $settingsPath
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
function Search-RegForPyPath {
    $pyCore = Get-ItemProperty -path "hkcu:\Software\Python\PythonCore\3.10\InstallPath" -ErrorAction SilentlyContinue
    if ($pyCore) {
        $pyPath = $pyCore.ExecutablePath
        logger.info "Python 3.10 path found :`n$pyPath"
        return $pyPath
    }
    else {
        logger.warn "Python 3.10 not found, you probably have the wrong version installed and the WebUI might not work"
        return ""
    }
    
}
function Format-Config($config) {
    $config2 = @()
    foreach ($param in $config) {
        $object = @{
            arg   = $param.arg
            value = $param.value
        }
        $config2 += $object
    }
    return $config2
}

function Select-Folder ([string]$InitialDirectory) {
    $app = New-Object -ComObject Shell.Application
    $folder = $app.BrowseForFolder(0, "Please select a folder", 0, "")
        
    if ($folder) { return $folder.Self.Path } else { return '' }
}

function  Select-File([string]$InitialDirectory) { 
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.InitialDirectory = $webuiPath
    $dialog.Title = "Please Select a File"
    If ($dialog.ShowDialog() -eq "Cancel") {
        return ''
    }   
    return $dialog.FileName 
}

function Clear-Outputs {
    $Exprompt = [system.windows.messagebox]::Show("All previously generated images will be deleted, are you sure ?`n`nClick 'No' to not delete any image this time`n`nUncheck 'Clear Generated Images' in the launcher to disable it", 'Warning', 'YesNo', 'Warning')
    if ($Exprompt -eq "Yes") {
        logger.action "Clearing all outputs in default output directories" 
        if ($outputsPath) {
            Get-ChildItem $outputsPath -Force -Recurse -File -Filter *.png | Remove-Item -Force
            Get-ChildItem $outputsPath -Force -Recurse -File -Filter *.jpg | Remove-Item -Force
        }
        logger.info "Done"
    }
}

#Updates
function Update-WebUI ($enabled) {
    if ($enabled) {
        logger.action "Updating Webui"
        Set-Location $webuiPath
        git pull origin
        logger.info "Done"
    }
}

function Update-Extensions ($enabled) {
    if ($enabled) {
        Set-Location $extPath
        $exts = Get-ChildItem $extPath -Directory
        if ($exts) {
            foreach ($ext in $exts) {         
                logger.action "Updating Extension: $ext"
                Set-Location $ext.Fullname
                git pull origin 
            }
            logger.info "Done"
            return
        }
        logger.info "No extension found in the extensions folder"
    }
}

#Clean JSon function
function Format-Json {
    <#
    .SYNOPSIS
        Prettifies JSON output.
    .DESCRIPTION
        Reformats a JSON string so the output looks better than what ConvertTo-Json outputs.
    .PARAMETER Json
        Required: [string] The JSON text to prettify.
    .PARAMETER Minify
        Optional: Returns the json string compressed.
    .PARAMETER Indentation
        Optional: The number of spaces (1..1024) to use for indentation. Defaults to 4.
    .PARAMETER AsArray
        Optional: If set, the output will be in the form of a string array, otherwise a single string is output.
    .EXAMPLE
        $json | ConvertTo-Json  | Format-Json -Indentation 2
    #>
    [CmdletBinding(DefaultParameterSetName = 'Prettify')]
    Param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Json,

        [Parameter(ParameterSetName = 'Minify')]
        [switch]$Minify,

        [Parameter(ParameterSetName = 'Prettify')]
        [ValidateRange(1, 1024)]
        [int]$Indentation = 4,

        [Parameter(ParameterSetName = 'Prettify')]
        [switch]$AsArray
    )

    if ($PSCmdlet.ParameterSetName -eq 'Minify') {
        return ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100 -Compress
    }

    # If the input JSON text has been created with ConvertTo-Json -Compress
    # then we first need to reconvert it without compression
    if ($Json -notmatch '\r?\n') {
        $Json = ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100
    }

    $indent = 0
    $regexUnlessQuoted = '(?=([^"]*"[^"]*")*[^"]*$)'

    $result = $Json -split '\r?\n' |
    ForEach-Object {
        # If the line contains a ] or } character, 
        # we need to decrement the indentation level unless it is inside quotes.
        if ($_ -match "[}\]]$regexUnlessQuoted") {
            $indent = [Math]::Max($indent - $Indentation, 0)
        }

        # Replace all colon-space combinations by ": " unless it is inside quotes.
        $line = (' ' * $indent) + ($_.TrimStart() -replace ":\s+$regexUnlessQuoted", ': ')

        # If the line contains a [ or { character, 
        # we need to increment the indentation level unless it is inside quotes.
        if ($_ -match "[\{\[]$regexUnlessQuoted") {
            $indent += $Indentation
        }

        $line
    }

    if ($AsArray) { return $result }
    return $result -Join [Environment]::NewLine
}
#Converts Object to hashtable
function Convert-PSObjectToHashtable {
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process {
        if ($null -eq $InputObject) { return $null }

        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            $collection = @(
                foreach ($object in $InputObject) { Convert-PSObjectToHashtable $object }
            )

            Write-Output -NoEnumerate $collection
        }
        elseif ($InputObject -is [psobject]) {
            $hash = @{}

            foreach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = Convert-PSObjectToHashtable $property.Value
            }

            $hash
        }
        else {
            $InputObject
        }
    }
}