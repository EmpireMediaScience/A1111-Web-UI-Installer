Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName Microsoft.VisualBasic
Set-StrictMode -Version 2
Import-Module .\logger.psm1 -Force -Global -Prefix "logger."

# General Variables
$InstallPath = (get-item $PSScriptRoot ).parent.FullName
<# $DocsPath = [environment]::getfolderpath("mydocuments")
$InstallPath = "$DocsPath\A1111's Web UI Autoinstaller" #>
$webuiPath = "$InstallPath\stable-diffusion-webui"
$launcherPath = "$InstallPath\Launcher"
$extPath = "$webuiPath\extensions"
$settingsPath = ".\settings.json"


# Ui general variables
$backgroundColor = [System.Drawing.ColorTranslator]::FromHtml("#000000")
$accentColor = [System.Drawing.ColorTranslator]::FromHtml("#ff9e36")
$primaryColor = [System.Drawing.ColorTranslator]::FromHtml("#1c0f01")
$secondaryColor = [System.Drawing.ColorTranslator]::FromHtml("#999999")
$buttonColor = [System.Drawing.ColorTranslator]::FromHtml("#111111")
$style = [System.Windows.Forms.FlatStyle]::Flat

