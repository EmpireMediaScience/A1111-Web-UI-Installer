function action {
    param (
        $object,
        [switch]$success
    )
    $color = "DarkMagenta"
    Write-Host " $([char]0x2192) " -BackgroundColor $color -ForegroundColor "Black" -NoNewline;
    if ($success) {
        Write-Host (" ", "$object ") -ForegroundColor $color -NoNewline
    }
    else {
        Write-Host (" ", "$object ") -ForegroundColor $color
    }
}
function info ($object, $path) {
    $color = "DarkGray"
    Write-Host " i " -BackgroundColor $color -ForegroundColor "Black" -NoNewline; Write-Host (" ", $object) -ForegroundColor $color -NoNewline; Write-Host (" ", $path) -ForegroundColor "White" 
}
function error ($object) {
    Write-Host " X " -BackgroundColor "Red" -ForegroundColor "Black" -NoNewline; Write-Host (" ", $object) -ForegroundColor "Red" 
}
function warn ($object) {
    Write-Host " ! " -BackgroundColor "Yellow" -ForegroundColor "Black" -NoNewline; Write-Host (" ", $object) -ForegroundColor "Yellow" 
}
function pop ($object) {
    $color = "Cyan"
    space $color
    Write-Host (" ", $object, " ") -BackgroundColor $color -ForegroundColor "Black"
    space $color
}
function web ($type, $object) {
    $color = "Blue"
    switch ($type) {
        "web" { $icon = ([char]0x2601) }
        "download" {
            space $color
            $icon = ([char]0x2193) 
        }
        "update" { 
            space $color
            $icon = ([char]0x21BA) 
        }
    }
    Write-Host (" $icon ") -BackgroundColor $color -ForegroundColor "Black" -NoNewline; Write-Host (" ", $object) -ForegroundColor $color
}
function dlprogress ($object) {
    $color = "DarkMagenta"
    Write-Host " $([char]0x2193) " -BackgroundColor $color -ForegroundColor "Black" -NoNewline; Write-Host (" ", "$object`r") -ForegroundColor $color -NoNewline
}
function space ($color) {
    for ($i = 1; $i -le 80; $i++) {
        Write-Host -NoNewline ([char]0x2501) -ForegroundColor $color
    }
    Write-Host ""
}
function success($object) {
    $color = "Green"
    if ($object) {
        Write-Host " $([char]0x2713) " -BackgroundColor $color -ForegroundColor "Black" -NoNewline
        Write-Host (" ", $object) -ForegroundColor $color
    }
    else {
        Write-Host " $([char]0x2713) " -BackgroundColor $color -ForegroundColor "Black"
    }
    
}