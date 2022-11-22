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

    $title = New-Object System.Windows.Forms.Label
    $title.Text = "AUTOMATIC1111 WEBUI"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Regular)
    $title.Size = "50,40"
    $title.Padding = "0,0,0,10"
    $title.Dock = "Top"
    $title.TextAlign = "middlecenter"
    $form.Controls.Add($title)
    
    $UIparams = foreach ($def in $defs) {
        $setting = $settings | Where-Object { $_.arg -eq $def.arg }
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
        $form.Controls.Add($UIparam)
        $paramDesc = New-Object System.Windows.Forms.Label
        $paramDesc.Text = $def.description
        $paramDesc.Tag = $def.arg + "desc"
        if ($setting.value) {
            $paramDesc.Text = $setting.value
        }
        $paramDesc.ForeColor = $secondaryColor
        $paramDesc.Dock = "Bottom"
        $paramDesc.Size = "200, 40"
        $form.Controls.Add($paramDesc)
        $UIparam
    }
    
    #Run & Exit

    $runbox = New-Object System.Windows.Forms.Panel
    $runbox.Dock = "Bottom"
    
    #Run
    $Runbutton = New-Object System.Windows.Forms.Button
    $Runbutton.Dock = "Top"
    $Runbutton.Text = "LAUNCH WEBUI"
    $Runbutton.Size = "50,50"
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