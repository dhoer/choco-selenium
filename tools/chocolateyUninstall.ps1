$ErrorActionPreference = 'Stop'; # stop on all errors

$pp = Get-PackageParameters
$toolsLocation = Get-ToolsLocation
$seleniumDir = "$toolsLocation\selenium"

if ($pp["role"] -eq $null -or $pp["role"] -eq '') { $pp["role"] = 'standalone' }

$name = "Selenium$((Get-Culture).TextInfo.ToTitleCase($pp["role"]))"

$rules = Get-NetFirewallRule
if ($rules.DisplayName.Contains($name)) {Remove-NetFirewallRule -DisplayName $name}

if ($pp["log"] -ne $null -and $pp["log"] -ne '' -and (Test-Path $pp["log"])) {
  Remove-Item $pp["log"]  -Force
}

if (Test-Path $seleniumDir) {
  $seleniumPath  = "$seleniumDir\selenium-server-standalone.jar"
  if (Test-Path $seleniumPath) {
    Remove-Item $seleniumPath -Force
  }

  $configPath = "$seleniumDir/$($pp["role"]).json"
  if (Test-Path $configPath) {
    Remove-Item $configPath -Force
  }

  $cmdPath = "$seleniumDir/$($pp["role"]).cmd"
  if (Test-Path $cmdPath) {
    Remove-Item $cmdPath -Force
  }

  $directoryInfo = Get-ChildItem $seleniumDir | Measure-Object
  If ($directoryInfo.count -eq 0) {
    Remove-Item $seleniumDir -Force
  }
}

$menuPrograms = [environment]::GetFolderPath([environment+specialfolder]::Programs)
$shortcutDir = "$menuPrograms\Selenium"

if (Test-Path $shortcutDir) {
  $shortcutFilePath = "$menuPrograms\Selenium\Selenium $((Get-Culture).TextInfo.ToTitleCase($pp["role"])).lnk"
  If (Test-Path $shortcutFile) {
    Remove-Item $shortcutFile -Force
  }

  $directoryInfo = Get-ChildItem $shortcutDir | Measure-Object
  If ($directoryInfo.count -eq 0) {
    Remove-Item $shortcutDir -Force
  }
}