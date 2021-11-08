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
  nssm start "$name"
} else {
  $cmdPath = "$seleniumDir\$($pp["role"]).cmd"
  $cmd | Set-Content $cmdPath

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

$configHash = Convert-TomlToHash($pp["config"])
Write-Debug "Config hash: $configHash"

$rules = Get-NetFirewallRule
$par = @{
    DisplayName = $configHash["port"]
    LocalPort   = "4446"
    Direction   = "Inbound"
    Protocol    = "TCP"
    Action      = "Allow"
}
if (-not $rules.DisplayName.Contains($par.DisplayName)) {New-NetFirewallRule @par}

Write-Debug "Selenium firewall: $par"
