Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName Microsoft.VisualBasic
Set-StrictMode -Version 2
Import-Module (Join-Path $PSScriptRoot 'logger.psm1') -Force -Global -Prefix "logger."

# General Variables
$tempFolder = (Get-Item -Path env:\temp).Value
$ProgressPreference = 'SilentlyContinue'
$PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine")

$InstallPath = (Get-Item $PSScriptRoot).Parent.FullName
$webuiPath = Join-Path $InstallPath "stable-diffusion-webui"
$modelsPath = Join-Path $webuiPath "models\Stable-diffusion"
$launcherPath = Join-Path $InstallPath "Launcher"
$extPath = Join-Path $webuiPath "extensions"
$settingsPath = Join-Path $PSScriptRoot "settings.json"
$outputsPath = Join-Path $webuiPath "outputs"
$hashPath = Join-Path $webuiPath ".git\refs\heads\master"
$configFile = Join-Path $webuiPath "config.json"

# Dependencies
$dependenciesPath = Join-Path $InstallPath "Dependencies"
$gitPath = Join-Path $env:ProgramFiles "Git"
$pyPath = ""

# Ui general variables
$backgroundColor = [System.Drawing.ColorTranslator]::FromHtml("#000000")
$accentColor = [System.Drawing.ColorTranslator]::FromHtml("#ff9e36")
$primaryColor = [System.Drawing.ColorTranslator]::FromHtml("#1c0f01")
$secondaryColor = [System.Drawing.ColorTranslator]::FromHtml("#999999")
$buttonColor = [System.Drawing.ColorTranslator]::FromHtml("#111111")
$style = [System.Windows.Forms.FlatStyle]::Flat
