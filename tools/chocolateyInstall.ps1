$ErrorActionPreference = 'Stop'; # stop on all errors

$toolsDir = Split-Path $MyInvocation.MyCommand.Definition
. $toolsDir\helpers.ps1

$packageName   = $env:ChocolateyPackageName
$url           = 'https://github.com/SeleniumHQ/selenium/releases/download/selenium-4.0.0/selenium-server-4.0.0.jar'
$checksum      = '0e381d119e59c511c62cfd350e79e4150df5e29ff6164dde03631e60072261a5'
$checksumType  = 'sha256'
$toolsLocation = Get-ToolsLocation
$seleniumDir   = "$toolsLocation\selenium"

$pp            = Get-SeleniumConfigDefaults
$name          = "Selenium $((Get-Culture).TextInfo.ToTitleCase($pp["role"]))"
$seleniumPath  = "$seleniumDir\selenium-server.jar"

if (!(Test-Path $seleniumDir)) {
  New-Item $seleniumDir -ItemType directory -Force
}

if (!(Test-Path $pp["config"])) {
  Copy-Item "$toolsDir\config.toml" $pp["config"]
}

# https://chocolatey.org/docs/helpers-get-chocolatey-web-file
Get-ChocolateyWebFile $packageName $seleniumPath $url -checksum $checksum -checksumType $checksumType

$options = "$($pp["role"]) --config ""$($pp["config"])"""
$cmdParams = "$($pp["javaoptions"]) -jar ""$seleniumPath"" $options"
$cmd = "java $cmdParams"
Write-Debug "Selenium command: $cmd"

if ($pp["service"] -eq $true) {
  nssm install "$name" java
  nssm set "$name" AppDirectory $seleniumDir
  nssm set "$name" AppParameters $cmdParams
  if ($pp["autostart"] -eq $true) {
    nssm set "$name" Start SERVICE_AUTO_START
  }
  if ($pp["log"]) {
    nssm set "$name" AppStdout $logPath
    nssm set "$name" AppStderr $logPath
    nssm set "$name" AppRotateFiles 1
  }
  nssm start "$name"
} else {
  $cmdPath = "$seleniumDir\$($pp["role"]).cmd"

  if ($pp["log"]) {
@"
@echo off
echo Starting $name...
for /f %%a in ('powershell -Command "Get-Date -format yyyyMMddTHHmmss"') do set datetime=%%a
if exist $logPath (
  move /Y $logPath $seleniumDir\$($pp["role"])-%datetime%.log >nul
  echo Rotated previous log
)
echo Logging to $logPath
"@ | Set-Content $cmdPath
    "$cmd > $logPath 2<&1" | Add-Content $cmdPath
  } else {
    $cmd | Set-Content $cmdPath
  }

  $menuPrograms = [Environment]::GetFolderPath('Programs')
  $shortcutArgs = @{
    shortcutFilePath = "$menuPrograms\Selenium\$name.lnk"
    targetPath       = $cmdPath
    iconLocation     = "$toolsDir\icon.ico"
    workDirectory    = $seleniumDir
  }
  Install-ChocolateyShortcut @shortcutArgs

  if ($pp["autostart"] -eq $true) {
    $startupArgs = @{
      shortcutFilePath = "$menuPrograms\Startup\$name.lnk"
      targetPath       = $cmdPath
      iconLocation     = "$toolsDir\icon.ico"
      workDirectory    = $seleniumDir
    }
    Install-ChocolateyShortcut @startupArgs
  }
}

$rules = Get-NetFirewallRule
$par = @{
    DisplayName = "$name"
    LocalPort   = "4444"
    Direction   = "Inbound"
    Protocol    = "TCP"
    Action      = "Allow"
}
if (-not $rules.DisplayName.Contains($par.DisplayName)) {New-NetFirewallRule @par}

Write-Debug "Selenium firewall: $par"
