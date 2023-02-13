# Init libraries

Add-Type -AssemblyName System.Windows.Forms

#Settings (later, put this in some json as a theme)

$Theme = [PSCustomObject]@{
    MainBGColor          = "#111111"
    SecondaryBGColor     = "#000000"
    MainAccentColor      = "#FFBB00"
    MainTextColor        = "#EEEEEE"
    SecondaryTextColor   = "#909090"
    MainButtonColor      = "#252525"
    MainHoverButtonColor = "#353535"
    MainDownButtonColor  = "#151515"
}

# Converting Theme Colors

foreach ($property in $Theme.PSObject.Properties) {
    $key = $property.Name
    $value = $property.Value
    if ($key -ilike "*Color") {
        $Theme.$key = [System.Drawing.ColorTranslator]::FromHtml($value)
    }
}
Write-Output $PSScriptRoot
Function New-MainForm {
    param($Size, $Title, [switch]$Header, $HeaderImage, [switch]$TopBar, [switch]$Settings, [String]$Validate, [switch]$Cancel)

    # Create a new form object
    $Form = New-Object System.Windows.Forms.Form
    $Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    # Font
    $Form.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 9, [System.Drawing.FontStyle]::Regular)
    # Geo
    $form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi
    $form.StartPosition = "CenterScreen"
    $form.AutoSize = $true
    # Appearance
    $form.ControlBox = $false
    $form.AllowTransparency = $true
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    <#     $form.add_Load({ $form.Region = New-Object System.Drawing.Region(New-RoundedRectangle $form.size 40) })
 #>
    # Colors
    $form.BackColor = $Theme.MainBGColor
    $form.ForeColor = $Theme.MainAccentColor

    # Top Bar
    $topBarPanel = New-Object System.Windows.Forms.Panel
    $topBarPanel.Height = 20
    $topBarPanel.Dock = "Top"
    $topBarPanel.Name = "Topbar"
    $topBarPanel.Padding = 4

    # Title
    
    $TitleText = New-Object System.Windows.Forms.Label
    $TitleText.Text = $Title
    $TitleText.Location = "3,2"
    $TitleText.ForeColor = $Theme.SecondaryTextColor
    $TitleText.Height = "15"

    if ($Title) {
        $form.Controls.Add($TitleText)
    }
    #Exit X
    $exitBTNImg = Get-ImgFromFile "$PSScriptRoot\Media\Nav\Exit.png"
    $exitBTN = New-Object System.Windows.Forms.PictureBox
    $exitBTN.Image = $exitBTNImg
    $exitBTN.SizeMode = "Zoom"
    $exitBTN.Size = "15,11"
    $exitBTN.Dock = "Right"
    $exitBTN.add_click({ 
            param($sender)
            $sender.Parent.Parent.Close()
        })
    
    #Settings
    if ($Settings) {

        $settingsBTNImg = Get-ImgFromFile "$PSScriptRoot\Media\Nav\Settings.png"
        $settingsBTN = New-Object System.Windows.Forms.PictureBox
        $settingsBTN.Name = "settingsBTN"
        $settingsBTN.Image = $settingsBTNImg
        $settingsBTN.SizeMode = "Zoom"
        $settingsBTN.Size = "20,15"
        $settingsBTN.Dock = "Right"
    
        $topBarPanel.Controls.Add($settingsBTN)
    }

    $topBarPanel.Controls.Add($exitBTN)

    #Header

    if ($Header) {
        $headerSpace = New-Object System.Windows.Forms.Panel
        $headerSpace.dock = "Top"
        $headerSpace.size = "1000,100"
        <#         $headerSpace.BackColor = "Red"
         #>

        if ($HeaderImage) {
            $HeaderImage = Get-ImgFromFile $HeaderImage
            $HeaderImg = new-object Windows.Forms.PictureBox
            $HeaderImg.Image = $HeaderImage
            $HeaderImg.Dock = "Fill"
            $HeaderImg.SizeMode = "Zoom"
            <#             $HeaderImg.Add_Click({ Open-SBFixer }) #>
            $headerSpace.Controls.add($HeaderImg)
        }
        $form.Controls.Add($headerSpace)
    }

    # Main Area
    $mainArea = New-Object System.Windows.Forms.Panel
    $mainArea.Padding = 25
    $mainArea.AutoSize = $true
    $mainArea.Dock = "Fill"
    $mainArea.BackColor = $Theme.SecondaryBGColor

    $form.Controls.Add($mainArea)



    #Cancel Button


    if ($TopBar) {
        $form.Controls.Add($topBarPanel)
    }

    if ($Validate) {
        # Validate Aera
        $ValidateArea = New-Object System.Windows.Forms.Panel
        $ValidateArea.AutoSize = $true
        $ValidateArea.Dock = "Bottom"
        $ValidateArea.Padding = "20,10,20,20"

        #Validate Button

        $ValidateBTN = New-MainButton -Text $Validate -Dock "Top" -Main
        $ValidateArea.Controls.Add($ValidateBTN)

        $form.Controls.Add($ValidateArea)

        if ($Cancel) {
            $cancelBTN = New-MainButton -Text "CANCEL" -Dock "Bottom"
            $cancelBTN.Controls["Button"].add_click({ param($sender)
                    $sender.Parent.Parent.Parent.Close() })
            $ValidateArea.Controls.Add($cancelBTN)
        }
    }
    
 
    # Return the form
    return $Form
}

Function New-RoundedButton {
    param($Text, $Dock)

    $Button = New-Object System.Windows.Forms.Button
    # Geo
    $Button.Dock = $Dock
    $Button.Anchor = "Top"
    $Button.Size = New-Object System.Drawing.Size(90, 30)
    <#  $Button.Location = New-Object System.Drawing.Point(100, 100) #>
    # Appearance
    $Button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $Button.FlatAppearance.BorderSize = 0
    <#     $Button.Region = New-Object System.Drawing.Region(New-RoundedRectangle $Button.Size 10) #>
    # Text
    $Button.Text = $Text
    # Colors
    $Button.BackColor = $Theme.MainButtonColor 
    $Button.ForeColor = $Theme.MainAccentColor 
    
    $Button.Add_MouseEnter({
            $this.BackColor = $Theme.MainHoverButtonColor
        })
    $Button.Add_MouseLeave({
            $this.BackColor = $Theme.MainButtonColor
        })
    $Button.Add_MouseDown({
            $this.BackColor = $Theme.MainDownButtonColor
        })
    $Button.Add_MouseUp( {
            $this.BackColor = $Theme.MainHoverButtonColor
        })
    <#     $Label = New-Object System.Windows.Forms.Label
    $Label.Size = $Button.Size
    $Label.Text = $Text
    $label.TextAlign = "middlecenter"

    $Label.Add_MouseEnter($enter)
    $Label.Add_MouseLeave($leave)
    $Label.Add_MouseDown($down)
    $Label.Add_MouseUp($up)
    
    $Button.Controls.Add($Label) #>

    return $Button
}

Function New-MainButton {
    param($Text, $Dock, [switch]$Main)

    $ButtonContainer = New-Object System.Windows.Forms.Panel
    $ButtonContainer.AutoSize = $true
    $ButtonContainer.Padding = 5
    $ButtonContainer.Dock = $Dock

    $Button = New-Object System.Windows.Forms.Button
    $Button.Name = "Button"
    # Geo
    $Button.Dock = "Top"
    $Button.AutoSize = $true
    # Appearance
    $Button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $Button.FlatAppearance.BorderSize = 0
    <#     $Button.Region = New-Object System.Drawing.Region(New-RoundedRectangle $Button.Size 10) #>
    
    # Text
    $Button.Text = $Text
    # Colors
    $Button.ForeColor = $Theme.SecondaryTextColor 
    if ($Main) {
        $Button.ForeColor = $Theme.MainAccentColor 
    }
    $Button.BackColor = $Theme.MainButtonColor 
    
    $Button.Add_MouseEnter({
            $this.BackColor = $Theme.MainHoverButtonColor
        })
    $Button.Add_MouseLeave({
            $this.BackColor = $Theme.MainButtonColor
        })
    $Button.Add_MouseDown({
            $this.BackColor = $Theme.MainDownButtonColor
        })
    $Button.Add_MouseUp( {
            $this.BackColor = $Theme.MainHoverButtonColor
        })
    <#     $Label = New-Object System.Windows.Forms.Label
    $Label.Size = $Button.Size
    $Label.Text = $Text
    $label.TextAlign = "middlecenter"

    $Label.Add_MouseEnter($enter)
    $Label.Add_MouseLeave($leave)
    $Label.Add_MouseDown($down)
    $Label.Add_MouseUp($up)
    
    $Button.Controls.Add($Label) #>

    $ButtonContainer.Controls.Add($Button)

    return $ButtonContainer
}

#Utils
Function New-RoundedRectangle ($size, $cornerRadius) {
    $rect = New-Object System.Drawing.Rectangle(0, 0, $size.Width, $size.Height)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc($rect.X, $rect.Y, $cornerRadius, $cornerRadius, 180, 90)
    $path.AddArc($rect.X + $rect.Width - $cornerRadius, $rect.Y, $cornerRadius, $cornerRadius, 270, 90)
    $path.AddArc($rect.X + $rect.Width - $cornerRadius, $rect.Y + $rect.Height - $cornerRadius, $cornerRadius, $cornerRadius, 0, 90)
    $path.AddArc($rect.X, $rect.Y + $rect.Height - $cornerRadius, $cornerRadius, $cornerRadius, 90, 90)
    $path.CloseAllFigures()
    return $path
}

function Get-ImgFromFile ($path) {
    return [System.Drawing.Image]::Fromfile((get-item $path))
}