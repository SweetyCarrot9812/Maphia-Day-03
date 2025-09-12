# Hanoa Desktop Shortcut Creation Script
$TargetFile = "C:\Users\tkand\Desktop\development\Hanoa\hanoa_desktop_flutter\build\windows\x64\runner\Debug\hanoa_desktop_flutter.exe"
$ShortcutFile = "$env:USERPROFILE\Desktop\Hanoa Desktop.lnk"
$WorkingDir = "C:\Users\tkand\Desktop\development\Hanoa\hanoa_desktop_flutter\build\windows\x64\runner\Debug"

# Create COM object
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)

# Set shortcut properties
$Shortcut.TargetPath = $TargetFile
$Shortcut.WorkingDirectory = $WorkingDir
$Shortcut.Description = "Hanoa Desktop - Educational Hub Platform"
$Shortcut.IconLocation = $TargetFile

# Save shortcut
$Shortcut.Save()

Write-Host "Hanoa Desktop shortcut created on Desktop!" -ForegroundColor Green
Write-Host "Location: $ShortcutFile" -ForegroundColor Cyan