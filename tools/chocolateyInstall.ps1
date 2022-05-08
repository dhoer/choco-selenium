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

# https://chocolatey.org/docs/helpers-get-chocolatey-web-file
Get-ChocolateyWebFile $packageName $seleniumPath $url -checksum $checksum -checksumType $checksumType

$options = "$($pp["role"])"
if ($null -ne $pp["config"] -or '' -ne $pp["config"] ) {
  $options = $options + " --config ""$($pp["config"])"""
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
  nssm start "$name"
} else {
  $cmdPath = "$seleniumDir\$($pp["role"]).cmd"
  $cmd | Set-Content $cmdPath

  $menuPrograms = [Environment]::GetFolderPath('Programs')
  $shortcutArgs = @{
    ShortcutFilePath = "$menuPrograms\Selenium\$name.lnk"
    TargetPath       = "$cmdPath"
    IconLocation     = "$toolsDir\icon.ico"
    WorkingDirectory = "$seleniumDir"
  }
  Install-ChocolateyShortcut @shortcutArgs

  if ($pp["autostart"] -eq $true) {
    $startupArgs = @{
      ShortcutFilePath = "$menuPrograms\Startup\$name.lnk"
      TargetPath       = "$cmdPath"
      IconLocation     = "$toolsDir\icon.ico"
      WorkingDirectory = "$seleniumDir"
    }
    Install-ChocolateyShortcut @startupArgs
  }
}
