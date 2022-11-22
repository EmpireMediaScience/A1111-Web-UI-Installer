Param(
    $settings
)

Set-Location $PSScriptRoot
. "$PSScriptRoot\shared.ps1"
Import-Module "$PSScriptRoot\logger.psm1" -Force -Global -Prefix "logger."
Import-Module "$PSScriptRoot\Functions.psm1" -Force

git config --global --add safe.directory '*'

# Executing updates
foreach ($setting in $settings) {
    if ($setting.arg -ilike "git*" -And $setting.enabled -eq $true) {
        switch ($setting.arg) {
            "git-Ext" { 
                Update-Extensions $true 
            }
            "git-UI" { 
                Update-WebUI $true 
            }
            Default {}
        }
    }
}

# Parsing args from settings
$arguments = Convert-SettingsToArguments $settings


Set-Location $webuiPath

$env:GIT = ""
$env:PYTHON = Search-RegForPyPath
$env:VENV_DIR = ""
$env:COMMANDLINE_ARGS = "--autolaunch " + $arguments

Start-Process "$webuiPath/webui.bat"
Set-Location $PSScriptRoot