$pp            = Get-PackageParameters
$toolsLocation = Get-ToolsLocation
$seleniumDir   = "$toolsLocation\selenium"
$menuPrograms  = [environment]::GetFolderPath([environment+specialfolder]::Programs)
$shortcutDir   = "$menuPrograms\Selenium"
$startupDir    = "$menuPrograms\Startup"
$names         = @("Selenium Standalone", "Selenium Hub", "Selenium Node")

foreach ($name in $names) {
  $service = Get-WmiObject -Class Win32_Service -Filter "Name='$name'"
	if ($service -ne $null) {
    nssm remove "$name" confirm
  }

  $rules = Get-NetFirewallRule
  if ($rules.DisplayName.Contains($name)) {Remove-NetFirewallRule -DisplayName $name}

  if (Test-Path $shortcutDir) {
    $shortcutFile = "$shortcutDir\$name.lnk"
    If (Test-Path $shortcutFile) {
      Remove-Item $shortcutFile -Force
    }

    $directoryInfo = Get-ChildItem $shortcutDir | Measure-Object
    If ($directoryInfo.count -eq 0) {
      Remove-Item $shortcutDir -Force
    }
  }

  if (Test-Path $startupDir) {
    $startupFile = "$startupDir\$name.lnk"
    If (Test-Path $startupFile) {
      Remove-Item $startupFile -Force
    }
  }
}

wmic Path win32_process Where "CommandLine Like '%selenium-server-standalone.jar%'" Call Terminate

if ($pp["capabilitiesJson"] -ne $null -and $pp["capabilitiesJson"] -ne '') {
  If (Test-Path $pp["capabilitiesJson"]) {
    Remove-Item $pp["capabilitiesJson"] -Force
  }
}

if (Test-Path $seleniumDir) {
  $seleniumPath  = "$seleniumDir\selenium-server-standalone.jar"
  if (Test-Path $seleniumPath) {
    Remove-Item $seleniumPath -Force
  }

  get-childitem $seleniumDir -include *.cmd -recurse | foreach ($_) {remove-item $_.fullname}
  get-childitem $seleniumDir -include *config.json -recurse | foreach ($_) {remove-item $_.fullname}
  get-childitem $seleniumDir -include *capabilities*.json -recurse | foreach ($_) {remove-item $_.fullname}
  get-childitem $seleniumDir -include *.log -recurse | foreach ($_) {remove-item $_.fullname}

  $directoryInfo = Get-ChildItem $seleniumDir | Measure-Object
  If ($directoryInfo.count -eq 0) {
    Remove-Item $seleniumDir -Force
  }
}
