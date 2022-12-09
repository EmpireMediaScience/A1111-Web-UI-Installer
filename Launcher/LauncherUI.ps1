Set-Location $PSScriptRoot
Import-Module .\Functions.psm1 -Force
. "$PSScriptRoot\shared.ps1"

# Ui general variables
$settings = Restore-Settings

function Invoke-WebUI {
    $form.Close()
    & .\LaunchWebUI.ps1 $settings
}
Function Update-UISettings($param) {
    Update-Settings $param $settings
    Convert-SettingsToArguments $settings
}
Function MakeNewForm {
    logger.info "Refreshing UI`n"
    $form.Close()
    $form.Dispose()
    MakeForm
}
function Makeform {
    $defs = Import-Defs

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
    $GeneralDesc.Dock = "Bottom"

    $GeneralContainer.Controls.Add($GeneralDesc)

    $UIparams = foreach ($def in $defs) {
        $setting = $settings | Where-Object { $_.arg -eq $def.arg }
        if ($def.type -eq "git") {
            $gitContainer = New-Object System.Windows.Forms.Panel
            $gitContainer.Dock = "Bottom"
            <#             $gitContainer.AutoSize = $true #>
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
            <# $paramDesc.Size = "200, 30" #>
            
            $gitContainer.Controls.Add($UIparam)
            $gitContainer.Controls.Add($forceBTN) 
            $gitContainer.Controls.Add($paramDesc)

            $GeneralContainer.Controls.Add($gitContainer)

            $UIparam
        }
    }
    $form.Controls.Add($GeneralContainer)

    $ArgContainer = New-Object System.Windows.Forms.Panel
    $ArgContainer.Dock = "Bottom"
    $ArgContainer.AutoSize = $true
    $ArgContainer.Padding = "10,10,10,5"

    $ArgDesc = New-Object System.Windows.Forms.Label
    $ArgDesc.Text = "Launch Options"
    $ArgDesc.Dock = "Bottom"

    $ArgContainer.Controls.Add($ArgDesc)

    $ArgParams = foreach ($def in $defs) {
        $setting = $settings | Where-Object { $_.arg -eq $def.arg }
        if ($def.type -ne "git" -and $def.type -ne "string") {        
            if ($def.type -eq "path") {
                $UIparam = New-Object System.Windows.Forms.Button
                $UIparam.BackColor = $buttonColor
            }
            else {
                $UIparam = New-Object System.Windows.Forms.Checkbox
                $UIparam.Checked = $setting.enabled
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

            $paramDesc = New-Object System.Windows.Forms.Label
            $paramDesc.Text = $def.description
            $paramDesc.Tag = $def.arg + "desc"
            if ($setting.value) {
                $paramDesc.Text = $setting.value
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

    $addDesc = New-Object System.Windows.Forms.Label
    $addDesc.Text = "Additional Arguments"
    $addDesc.Dock = "Bottom"
    $addDesc.Size = "200, 20"
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
    $Runbutton.Add_Click({ Invoke-WebUI })
    $Runbutton.FlatStyle = $style
    $runbox.Controls.Add($Runbutton)

    #Exit
    $Exitbutton = New-Object System.Windows.Forms.Button
    $Exitbutton.Dock = "Bottom"
    $Exitbutton.Text = "EXIT"
    $Exitbutton.Size = "50,30"
    $Exitbutton.ForeColor = "White"
    $Exitbutton.Add_Click({ $form.Close() })
    $Exitbutton.FlatStyle = $style
    $runbox.Controls.Add($Exitbutton)

    $form.Controls.Add($runbox)

    $Form.ShowDialog()
}
logger.action "Opening A1111 WebUI Launcher"
MakeForm