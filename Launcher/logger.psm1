function action ($object) {
    Write-Host "[ACTION]" -BackgroundColor "Green" -ForegroundColor "Black" -NoNewline; Write-Host ("", $object) -ForegroundColor "Green" 
}
function info ($object) {
    Write-Host "[INFO]" -BackgroundColor "Blue" -ForegroundColor "White" -NoNewline; Write-Host ("", $object) 
}
function error ($object) {
    Write-Host "[ERROR]" -BackgroundColor "Red" -ForegroundColor "White" -NoNewline; Write-Host ("", $object) -ForegroundColor "Red" 
}
function warn ($object) {
    Write-Host "[WARNING]" -BackgroundColor "Yellow" -ForegroundColor "Black" -NoNewline; Write-Host ("", $object) -ForegroundColor "Yellow" 
}
function pop ($object) {
    Write-Host "[POP]" -BackgroundColor "Magenta" -ForegroundColor "Black" -NoNewline; Write-Host ("", $object) -ForegroundColor "Magenta" 
}