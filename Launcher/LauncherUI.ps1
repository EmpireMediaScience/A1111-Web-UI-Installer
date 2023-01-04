Set-Location $PSScriptRoot
Import-Module .\Functions.psm1 -Force
. "$PSScriptRoot\shared.ps1"

# Ui general variables
$settings = Restore-Settings
$Version = Get-Version
if ($args.Length -gt 0) {
    logger.info "Launching with args : $args"
}
else {
    logger.info "Launching without args"
}

$GPUInfo = Get-GPUInfo
$GPUText = "No Compatible GPU Found"
if ($GPUInfo) {
    $GPUText = "$($GPUInfo.Model) $($GPUInfo.VRAM) GB"
}

Install-py
Install-git
Install-WebUI
Import-BaseModel

$Hash = Get-WebUICommitHash
$HashText = "No Hash Found"
if ($Hash) {
    $HashText = "$($Hash.Substring(0, 7))..."
}

Function MakeNewForm {
    logger.info "Refreshing UI`n"
    $form.Close()
    $form.Dispose()
    MakeForm
}
function Invoke-WebUI {
    Param(
        $settings
    )

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
                "git-ClearOutputs" {
                    Clear-Outputs
                }
                Default {}
            }
        }
    }

    # Parsing args from settings
    $arguments = Convert-SettingsToArguments $settings

    logger.pop "WEBUI LAUNCHING VIA EMS LAUNCHER, EXIT THIS WINDOW TO STOP THE WEBUI"
    logger.warn "Any error happening after 'commit hash : XXXX' or 'Installing Torch...' bellow is not related to the launcher please report them on Automatic1111's github instead :"
    logger.web -type "web" "https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/new/choose"
    logger.space "Yellow"
    
    Set-Location $webuiPath

    $env:PYTHON = "`"$pyPath`""
    <#
    $env:GIT_PYTHON_GIT_EXECUTABLE = "$gitPath"
    $env:GIT = $gitPath 
    #>
    $env:COMMANDLINE_ARGS = "--autolaunch " + $arguments

    Start-Process "$webuiPath/webui.bat" -NoNewWindow
    Set-Location $PSScriptRoot
}


if ($args -contains "skip") {
    logger.pop "Skipping Launcher UI"
    Invoke-WebUI $settings
    return
}
Function Reset-Path($param) {
    $setting = $settings | Where-Object { $_.arg -eq $param.Name }
    $setting.enabled = $false
    $setting.value = ""
    $argsies = Convert-SettingsToArguments $settings
    Write-Settings $settings
    MakeNewForm
    $ArgsField.text = $argsies
}

Function Update-UISettings($param) {
    Update-Settings $param $settings
    $argsies = Convert-SettingsToArguments $settings
    $ArgsField.text = $argsies
}

function Makeform {
    $defs = Import-Defs
    $argsies = Convert-SettingsToArguments $settings

    $form = New-Object System.Windows.Forms.Form
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = $backgroundColor
    $form.ForeColor = $accentColor
    $form.Font = "Segoe UI"
    $form.AllowTransparency = $true
    $form.FormBorderStyle = "FixedSingle"
    $form.ControlBox = $false
    $form.AutoSize = $true
    $form.Padding = 20
    $form.Size = "350,500"

    $versionLabel = New-Object System.Windows.Forms.Label
    $versionLabel.Text = "Launcher V$($Version.Long)"
    $versionLabel.ForeColor = $secondaryColor
    $form.Controls.Add($versionLabel)

    $title = New-Object System.Windows.Forms.Label
    $title.Text = "AUTOMATIC1111 WEBUI"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Regular)
    $title.Size = "50,40"
    $title.Padding = "0,0,0,10"
    $title.Dock = "Top"
    $title.TextAlign = "middlecenter"
    $form.Controls.Add($title)
    
    #Git & General Options
    $GeneralContainer = New-Object System.Windows.Forms.Panel
    $GeneralContainer.Dock = "Bottom"
    $GeneralContainer.BackColor = $buttonColor
    $GeneralContainer.AutoSize = $true
    $GeneralContainer.Padding = "10,5,10,0"

    $GeneralDesc = New-Object System.Windows.Forms.Label
    $GeneralDesc.Text = "General Settings"
    $GeneralDesc.TextAlign = "MiddleCenter" 
    $GeneralDesc.Dock = "Bottom"

    $GeneralContainer.Controls.Add($GeneralDesc)

    $UIparams = foreach ($def in $defs) {
        $setting = $settings | Where-Object { $_.arg -eq $def.arg }
        if ($def.type -eq "git") {
            $gitContainer = New-Object System.Windows.Forms.Panel
            $gitContainer.Dock = "Bottom"
            $gitContainer.Size = "150,50"
            $gitContainer.Padding = "0,5,0,5"

            $UIparam = New-Object System.Windows.Forms.Checkbox
            $UIparam.Checked = $setting.enabled
            $UIparam.Add_Click({ 
                    Update-UISettings $this
                    if ($this.tag -eq "path") { MakeNewForm }
                })  
            $UIparam.TabIndex = 2
            $UIparam.ForeColor = "White"
            $UIparam.Tag = $def.type
            $UIparam.Name = $def.arg
            $UIparam.Text = $def.name
            $UIparam.Size = "150, 20"
            $UIparam.Dock = "Left"

            $forceBTN = New-Object System.Windows.Forms.Button
            $forceBTN.Text = "Force"
            $forceBTN.Tag = $def.arg
            $forceBTN.BackColor = "Black"
            $forceBTN.Add_Click({
                    switch ($this.Tag) {
                        "git-Ext" { 
                            Update-Extensions $true 
                        }
                        "git-UI" { 
                            Update-WebUI $true 
                        }
                        "git-ClearOutputs" {
                            Clear-Outputs
                        }
                        Default {}
                    }
                })
            $forceBTN.Size = "50, 20"
            $forceBTN.Dock = "Right"

            $paramDesc = New-Object System.Windows.Forms.Label
            $paramDesc.Text = $def.description
            $paramDesc.Tag = $def.arg + "desc"
            $paramDesc.ForeColor = $secondaryColor
            $paramDesc.Dock = "Bottom"
            
            $gitContainer.Controls.Add($UIparam)
            $gitContainer.Controls.Add($forceBTN) 
            $gitContainer.Controls.Add($paramDesc)

            $GeneralContainer.Controls.Add($gitContainer)

            $UIparam
        }
    }
    $form.Controls.Add($GeneralContainer)

    #WebUI Args
    $ArgContainer = New-Object System.Windows.Forms.Panel
    $ArgContainer.Dock = "Bottom"
    $ArgContainer.AutoSize = $true
    $ArgContainer.Padding = "10,10,10,5"

    $ArgDesc = New-Object System.Windows.Forms.Label
    $ArgDesc.Text = "Launch Options"
    $ArgDesc.TextAlign = "MiddleCenter"
    $ArgDesc.Dock = "Bottom"

    $ArgContainer.Controls.Add($ArgDesc)

    $ArgParams = foreach ($def in $defs) {
        $setting = $settings | Where-Object { $_.arg -eq $def.arg }
        if ($def.type -ne "git" -and $def.type -ne "string") {        
            if ($def.type -eq "path") {
                $UIparam = New-Object System.Windows.Forms.Button
                $UIparam.BackColor = $buttonColor
                $paramDesc = New-Object System.Windows.Forms.LinkLabel
                $paramDesc.LinkColor = $secondaryColor
                $paramDesc.LinkBehavior = [System.Windows.Forms.LinkBehavior]::NeverUnderline;
            }
            else {
                $UIparam = New-Object System.Windows.Forms.Checkbox
                $UIparam.Checked = $setting.enabled
                $paramDesc = New-Object System.Windows.Forms.Label
            }
          
            $UIparam.Add_Click({ 
                    Update-UISettings $this
                    if ($this.tag -eq "path") { MakeNewForm }
                })  
            $UIparam.TabIndex = 2
            $UIparam.ForeColor = "White"
            $UIparam.Tag = $def.type
            $UIparam.Name = $def.arg
            $UIparam.Text = $def.name
            $UIparam.Dock = "Bottom"
            $UIparam.Size = "100, 20"     
            $paramDesc.Text = $def.description
            $paramDesc.Tag = $def.arg + "desc"
            $paramDesc.Name = $def.arg
            if ($setting.value) {
                if ($setting.value.Length -lt 25) {
                    $paramDesc.Text = "RESET - $($setting.value)" 
                }
                else {
                    $paramDesc.Text = "RESET - $($setting.value.Substring(0, 25))..."  
                }
                
                $paramDesc.Add_Click({ Reset-Path $this })
            }
            $paramDesc.ForeColor = $secondaryColor
            $paramDesc.Dock = "Bottom"
            $paramDesc.Size = "200, 30"

            $ArgContainer.Controls.Add($UIparam)
            if ($def.type -eq "git") { 
                $ArgContainer.Controls.Add($forceBTN) 
            }
            $ArgContainer.Controls.Add($paramDesc)
            $UIparam        
        }
    }

    $addDesc = New-Object System.Windows.Forms.LinkLabel
    $addDesc.LinkColor = $accentColor
    $addDesc.LinkBehavior = [System.Windows.Forms.LinkBehavior]::NeverUnderline;
    $addDesc.Text = "Additional Launch Options (Click Here to See The List)"
    $addDesc.TextAlign = "MiddleCenter" 
    $addDesc.Dock = "Bottom"
    $addDesc.Size = "200, 20"
    $addDesc.Add_Click({ Start-Process "https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Command-Line-Arguments-and-Settings" })
    $ArgContainer.Controls.Add($addDesc)

    $adds = $settings | Where-Object { $_.arg -eq "add" }

    $additional = New-Object System.Windows.Forms.RichTextBox
    $additional.Name = "add"
    $additional.Dock = "Bottom"
    $additional.Size = "100,50"
    $additional.Text = $adds.value
    $additional.ShortcutsEnabled = $true
    $additional.ScrollBars = "Vertical"
    $additional.Multiline = $true
    $additional.BackColor = "Black"
    $additional.ForeColor = "White"
    $additional.Tag = "string"
    $ArgContainer.Controls.Add($additional)

    $addSave = New-Object System.Windows.Forms.Button
    $addSave.Text = "SAVE"
    $addSave.Dock = "Bottom"
    $addSave.BackColor = $buttonColor
    $addSave.Add_Click({ Update-UISettings $additional })
    $ArgContainer.Controls.Add($addSave)

    $form.Controls.Add($ArgContainer)
    
    #Args

    $argsText = New-Object System.Windows.Forms.Label
    $argsText.TextAlign = "MiddleCenter" 
    $argsText.Text = "Overview"
    $argsText.Dock = "Bottom"
    $form.Controls.Add($argsText)

    $ArgsField = New-Object System.Windows.Forms.TextBox
    $ArgsField.Multiline = $true
    $ArgsField.Size = "1000,60"
    $ArgsField.ScrollBars = "Vertical"
    $ArgsField.Dock = "Bottom"
    $ArgsField.ReadOnly = $true
    $ArgsField.BorderStyle = "None"
    $ArgsField.BackColor = $buttonColor
    $ArgsField.ForeColor = $accentColor
    $ArgsField.Text = $argsies
    $Form.Controls.Add($ArgsField)

    #Run & Exit

    $runbox = New-Object System.Windows.Forms.Panel
    $runbox.Dock = "Bottom"
    $runbox.Padding = "0,15,0,0"
    
    #Run
    $Runbutton = New-Object System.Windows.Forms.Button
    $Runbutton.Dock = "Top"
    $Runbutton.Text = "LAUNCH WEBUI"
    $Runbutton.Size = "50,40"
    $Runbutton.ForeColor = $accentColor
    $Runbutton.Add_Click({ 
            Invoke-WebUI $settings
            $form.Close()
        })
    $Runbutton.FlatStyle = $style
    $runbox.Controls.Add($Runbutton)

    #Exit
    $Exitbutton = New-Object System.Windows.Forms.Button
    $Exitbutton.Dock = "Bottom"
    $Exitbutton.Text = "EXIT"
    $Exitbutton.Size = "50,30"
    $Exitbutton.ForeColor = "White"
    $Exitbutton.Add_Click({
            $form.Close()
        })
    $Exitbutton.FlatStyle = $style
    $runbox.Controls.Add($Exitbutton)

    $form.Controls.Add($runbox)

    # Hardware Info

    $HWContainer = New-Object System.Windows.Forms.Panel
    $HWContainer.Dock = "Bottom"
    $HWContainer.Size = "1000,80"

    $GPULabel = New-Object System.Windows.Forms.Label
    $GPULabel.Text = $GPUText
    $GPULabel.TextAlign = "MiddleCenter"
    $GPULabel.ForeColor = $secondaryColor
    $GPULabel.Dock = "Bottom"
    $HWContainer.Controls.Add($GPULabel)

    $HashLabel = New-Object System.Windows.Forms.LinkLabel
    $HashLabel.Text = "WebUI Hash (Click to copy) : $HashText"
    $HashLabel.TextAlign = "MiddleCenter"
    $HashLabel.LinkColor = $secondaryColor
    $HashLabel.LinkBehavior = [System.Windows.Forms.LinkBehavior]::NeverUnderline;
    $HashLabel.Add_Click({ 
            Set-Clipboard $Hash
            logger.info $Hash, "copied to the clipboard" 
        })
    $HashLabel.Dock = "Bottom"
    $HWContainer.Controls.Add($HashLabel)

    $helpLabel = New-Object System.Windows.Forms.LinkLabel
    $helpLabel.Text = "Launcher Help"
    $helpLabel.LinkColor = $secondaryColor
    $helpLabel.LinkBehavior = [System.Windows.Forms.LinkBehavior]::NeverUnderline;
    $helpLabel.Add_Click({ Start-Process "https://github.com/EmpireMediaScience/A1111-Web-UI-Installer/issues" })
    $helpLabel.Dock = "Bottom"
    $helpLabel.Size = "1000,15"
    $helpLabel.TextAlign = "MiddleCenter"
    $HWContainer.Controls.Add($helpLabel)

    $LhelpLabel = New-Object System.Windows.Forms.LinkLabel
    $LhelpLabel.Text = "WebUI Help"
    $LhelpLabel.LinkColor = $secondaryColor
    $LhelpLabel.LinkBehavior = [System.Windows.Forms.LinkBehavior]::NeverUnderline;
    $LhelpLabel.Add_Click({ Start-Process "https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/new/choose" })
    $LhelpLabel.Dock = "Bottom"
    $LhelpLabel.Size = "1000,15"
    $LhelpLabel.TextAlign = "MiddleCenter"
    $HWContainer.Controls.Add($LhelpLabel)

    $Form.Controls.Add($HWContainer)

    $Form.ShowDialog()
}

logger.pop "Opening A1111 WebUI Launcher"

MakeForm