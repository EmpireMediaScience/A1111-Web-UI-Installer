function action ($object) {
    $color = "DarkMagenta"
    space $color
    Write-Host " $([char]0x25b6) " -BackgroundColor $color -ForegroundColor "Black" -NoNewline; Write-Host (" ", $object) -ForegroundColor $color
}
function info ($object) {
    Write-Host " $([char]0x2139) " -BackgroundColor "DarkGray" -ForegroundColor "Black" -NoNewline; Write-Host (" ", $object) -ForegroundColor "DarkGray" 
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
function web ($object) {
    $color = "Blue"
    Write-Host (" $([char]0x2601) ") -BackgroundColor $color -ForegroundColor "Black" -NoNewline; Write-Host (" ", $object) -ForegroundColor $color
}
function space ($color) {
    for ($i = 1; $i -le 80; $i++) {
        # Print the character "X"
        Write-Host -NoNewline ([char]0x2501) -ForegroundColor $color
    }
    Write-Host ""
}
function success {
    $color = "Green"
    Write-Host " $([char]0x2714) " -BackgroundColor $color -ForegroundColor "Black" -NoNewline; Write-Host (" ", "SUCCESS") -ForegroundColor $color
    space $color
}