# PowerShell Script - Create Clintest Desktop Shortcut

$WshShell = New-Object -ComObject WScript.Shell

# Desktop path
$DesktopPath = [Environment]::GetFolderPath("Desktop")

# Shortcut file path
$ShortcutPath = "$DesktopPath\Clintest Desktop.lnk"

# Target executable path
$TargetPath = "C:\Users\tkand\Desktop\development\Hanoa\clintest_flutter_desktop\build\windows\x64\runner\Debug\clintest_flutter_desktop.exe"

# Working directory
$WorkingDirectory = "C:\Users\tkand\Desktop\development\Hanoa\clintest_flutter_desktop\build\windows\x64\runner\Debug"

# Create shortcut
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $TargetPath
$Shortcut.WorkingDirectory = $WorkingDirectory
$Shortcut.Description = "Clintest Desktop - Flutter-based Clinical Trial Management System"
$Shortcut.Save()

Write-Host "Desktop shortcut created: $ShortcutPath"
Write-Host "Target executable: $TargetPath"