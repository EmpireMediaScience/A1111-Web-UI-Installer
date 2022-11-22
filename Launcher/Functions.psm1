. "$PSScriptRoot\shared.ps1"
Import-Module "$PSScriptRoot\logger.psm1" -Force -Global -Prefix "logger."

# General Utilities
function Write-Settings($settings) {
    logger.action "Updating Settings File"
    $settings | ConvertTo-Json -Depth 100 | Out-File $settingsPath
}
function New-Settings {
    logger.action "Settings not file found, creating"
    $defs = Import-Defs
    $settings = @()
    for ($i = 0; $i -lt $defs.Count; $i++) {
        $settings += @{ 
            arg     = $defs[$i].arg
            enabled = $false
            value   = "" 
        }
    }
    Write-Settings $settings
    return $settings
}
function Restore-Settings {
    
    if (Test-Path $settingsPath) {
        $settingsfile = Get-Content $settingsPath
        logger.action "Settings file found, loading"
        $settings = $settingsfile | ConvertFrom-Json
    }
    else {
        $settings = New-Settings
    }
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
            <# Action to perform if the condition is true #>
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
    logger.info "Arguments are now:", $string
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
    $pyCore = Get-ItemProperty -path "hkcu:\Software\Python\PythonCore\3.10\InstallPath"
    if ($pyCore) {
        $path = $pyCore.ExecutablePath
        logger.info "Python 3.10 path found :`n$path"
        return $path
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
    }
}

#Updates
function Update-WebUI ($enabled) {
    if ($enabled) {
        logger.action "Updating Webui"
        Set-Location $webuiPath
        git pull origin
    }
}

function Update-Extensions ($enabled) {
    if ($enabled) {
        Set-Location $extPath
        $exts = Get-ChildItem $extPath -Directory
        if ($exts) {
            foreach ($ext in $exts) {         
                logger.action "Updating Extension: $ext"
                Set-Location $ext
                git pull origin 
            }
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

