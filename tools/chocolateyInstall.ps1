$ErrorActionPreference = 'Stop'; # stop on all errors

$toolsDir = Split-Path $MyInvocation.MyCommand.Definition
. $toolsDir\helpers.ps1

$packageName   = $env:ChocolateyPackageName
$url           = 'https://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-3.141.59.jar'
$checksum      = 'acf71b77d1b66b55db6fb0bed6d8bae2bbd481311bcbedfeff472c0d15e8f3cb'
$checksumType  = 'sha256'
$toolsLocation = Get-ToolsLocation
$seleniumDir   = "$toolsLocation\selenium"

$pp            = Get-SeleniumConfigDefaults
$name          = "Selenium $((Get-Culture).TextInfo.ToTitleCase($pp["role"]))"
$seleniumPath  = "$seleniumDir\selenium-server-standalone.jar"

if (!(Test-Path $seleniumDir)) {
  New-Item $seleniumDir -ItemType directory -Force
}

if ($pp["log"]) {
  $logPath  = "$seleniumDir\$($pp["role"]).log"
  Write-Debug "Selenium log: $logPath"
}

if ($pp["role"] -eq 'node') {
  if ($pp["capabilitiesJson"] -eq $null -or $pp["capabilitiesJson"] -eq '') {
    $pp["capabilitiesJson"] = "$seleniumDir\capabilities.json"
    $capabilitiesPath = "$toolsDir\capabilities.json"
    if (!(Test-Path $pp["capabilitiesJson"])) {
      Copy-Item $capabilitiesPath $pp["capabilitiesJson"]
    }
  }
  # https://stackoverflow.com/a/38212718/4548096
  $pp["capabilities"] = (Get-Content -Path $pp["capabilitiesJson"] -Raw).Replace("`r`n","`n") | ConvertFrom-Json | % { $_ }
  if ($pp["capabilities"] -isnot [Array]) { $pp["capabilities"] = @($pp["capabilities"]) }
  Browser-AutoVersion($pp["capabilities"])
}

# https://chocolatey.org/docs/helpers-get-chocolatey-web-file
Get-ChocolateyWebFile $packageName $seleniumPath $url -checksum $checksum -checksumType $checksumType

$config = Get-SeleniumConfig ($pp)
$configPath = "$seleniumDir\$($pp["role"])config.json"

if ($pp["role"] -ne 'standalone') {
   $config | ConvertTo-Json -Depth 99 | Set-Content $configPath
   Write-Debug "Selenium configuration: $(type $configPath)"
}

if ($pp["role"] -eq 'hub') {
  $options = "-role hub -hubConfig ""$configPath"""
} elseif ($pp["role"] -eq 'node' ) {
  $options = "-role node -nodeConfig ""$configPath"""
} else { # standalone
  $keys = $config.keys
  foreach ($key in $keys) {
    if ($key -eq 'debug') {
      if ($config[$key] -eq $true) { $options += "-$key " }
    } else {
      $options += "-$key "
      if ($config[$key] -is [String] -and $key -ne 'role') {
        $options += """"
        $options += $config[$key]
        $options += """"
      } else {
        $options += $config[$key]
      }
      $options += " "
    }
  }
}

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
    LocalPort   = $pp["port"]
    Direction   = "Inbound"
    Protocol    = "TCP"
    Action      = "Allow"
}
if (-not $rules.DisplayName.Contains($par.DisplayName)) {New-NetFirewallRule @par}

Write-Debug "Selenium firewall: $par"
