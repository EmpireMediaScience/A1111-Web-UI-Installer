function action ($object) {
    $color = "DarkMagenta"
    space $color
    Write-Host " $([char]0x2192) " -BackgroundColor $color -ForegroundColor "Black" -NoNewline; Write-Host (" ", $object) -ForegroundColor $color
}
function info ($object) {
    Write-Host " i " -BackgroundColor "DarkGray" -ForegroundColor "Black" -NoNewline; Write-Host (" ", $object) -ForegroundColor "DarkGray" 
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
function space ($color) {
    for ($i = 1; $i -le 80; $i++) {
        Write-Host -NoNewline ([char]0x2501) -ForegroundColor $color
    }
    Write-Host ""
}
function success {
    $color = "Green"
    Write-Host " $([char]0x2713) " -BackgroundColor $color -ForegroundColor "Black" -NoNewline; Write-Host (" ", "SUCCESS") -ForegroundColor $color
    space $color
}