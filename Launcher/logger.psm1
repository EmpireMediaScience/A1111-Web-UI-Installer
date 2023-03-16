function Write-OutputWithStyle {
    param (
        [string]$Icon,
        [string]$Object,
        [string]$Color,
        [string]$BgColor = $null,
        [switch]$NoNewline
    )
    if ($BgColor) {
        Write-Host " $Icon " -BackgroundColor $BgColor -ForegroundColor "Black" -NoNewline
    }
    Write-Host (" ", $Object) -ForegroundColor $Color -NoNewline:$NoNewline
}

function Write-HorizontalLine {
    param (
        [string]$Color
    )
    for ($i = 1; $i -le 80; $i++) {
        Write-Host -NoNewline ([char]0x2501) -ForegroundColor $Color
    }
    Write-Host ""
}

function Action {
    param (
        [string]$Object,
        [switch]$Success
    )
    $color = "DarkMagenta"
    Write-OutputWithStyle -Icon ([char]0x2192) -Object $Object -Color $Color -BgColor $Color -NoNewline:$Success
}

function Info {
    param (
        [string]$Object,
        [string]$Path
    )
    $color = "DarkGray"
    Write-OutputWithStyle -Icon "i" -Object "$Object $Path" -Color $Color -BgColor $Color
}

function Error {
    param (
        [string]$Object
    )
    Write-OutputWithStyle -Icon "X" -Object $Object -Color "Red" -BgColor "Red"
}

function Warn {
    param (
        [string]$Object
    )
    Write-OutputWithStyle -Icon "!" -Object $Object -Color "Yellow" -BgColor "Yellow"
}

function Pop {
    param (
        [string]$Object
    )
    $color = "Cyan"
    Write-HorizontalLine -Color $Color
    Write-OutputWithStyle -Icon "" -Object $Object -Color "Black" -BgColor $Color
    Write-HorizontalLine -Color $Color
}

function Web {
    param (
        [string]$Type,
        [string]$Object
    )
    $color = "Blue"
    switch ($Type) {
        "web" { $icon = ([char]0x2601) }
        "download" {
            Write-HorizontalLine -Color $Color
            $icon = ([char]0x2193)
        }
        "update" { 
            Write-HorizontalLine -Color $Color
            $icon = ([char]0x21BA)
        }
    }
    Write-OutputWithStyle -Icon $Icon -Object $Object -Color $Color -BgColor $Color
}

function DlProgress {
    param (
        [string]$Object
    )
    $color = "DarkMagenta"
    Write-OutputWithStyle -Icon ([char]0x2193) -Object ("$Object`r") -Color $Color -BgColor $Color -NoNewline
}

function Success {
    param (
        [string]$Object
    )
    $color = "Green"
    Write-OutputWithStyle -Icon ([char]0x2713) -Object $Object -Color $Color -BgColor $Color
}
