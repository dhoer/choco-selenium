$ErrorActionPreference = 'Stop'; # stop on all errors

$toolsDir = Split-Path $MyInvocation.MyCommand.Definition
. $toolsDir\helpers.ps1

$packageName   = $env:ChocolateyPackageName
$url           = 'https://selenium-release.storage.googleapis.com/3.5/selenium-server-standalone-3.5.3.jar'
$checksum      = '3dd4cad1d343f9d1cb1302ef1b3cec98'
$checksumType  = 'md5'
$toolsLocation = Get-ToolsLocation
$seleniumDir   = "$toolsLocation\selenium"
$seleniumPath  = "$seleniumDir\selenium-server-standalone.jar"
$pp            = Get-SeleniumConfigDefaults
$name          = "Selenium$((Get-Culture).TextInfo.ToTitleCase($pp["role"]))"

if (!(Test-Path $seleniumDir)) {
  New-Item $seleniumDir -ItemType directory
}

if ($pp["log"] -ne $null -and $pp["log"] -ne '' -and !(Test-Path $pp["log"])) {
  New-Item -ItemType "file" -Path $pp["log"]
}

# https://chocolatey.org/docs/helpers-get-chocolatey-web-file
Get-ChocolateyWebFile $packageName $seleniumPath $url -checksum $checksum -checksumType $checksumType

  $config = @{}

  $config["role"] = $pp["role"]
  $config["port"] = $pp["port"]
  $config["browserTimeout"] = $pp["browserTimeout"]
  $config["timeout"] = $pp["timeout"]
  $config["debug"] = $pp["debug"]
  $config["enablePassThrough"] = $pp["enablePassThrough"]

  if ($pp["jettyMaxThreads"] -ne $null -and $pp["jettyMaxThreads"] -ne '') { $config["jettyMaxThreads"] = $pp["jettyMaxThreads"] }
  if ($pp["log"] -ne $null -and $pp["log"] -ne '') { $config["log"] = $pp["log"] }

  if ($pp["role"] -eq 'hub') {
    $config["newSessionWaitTimeout"] = $pp["newSessionWaitTimeout"]
    $config["capabilityMatcher"] = $pp["capabilityMatcher"]
    $config["maxSession"] = $pp["maxSession"]
    $config["newSessionWaitTimeout"] = $pp["newSessionWaitTimeout"]
    $config["throwOnCapabilityNotPresent"] = $pp["throwOnCapabilityNotPresent"]
    $config["servlets"] = $pp["servlets"]
    $config["withoutServlets"] = $pp["withoutServlets"]

    if ($pp["prioritizer"] -ne $null -and $pp["prioritizer"] -ne '') { $config["prioritizer"] = $pp["prioritizer"] }
  } elseif ($pp["role"] -eq 'node' ) {
    $config["cleanUpCycle"] = $pp["cleanUpCycle"]
    $config["downPollingLimit"] = $pp["downPollingLimit"]
    $config["hub"] = $pp["hub"]
    $config["maxSession"] = $pp["maxSession"]
    $config["nodePolling"] = $pp["nodePolling"]
    $config["nodeStatusCheckTimeout"] = $pp["nodeStatusCheckTimeout"]
    $config["proxy"] = $pp["proxy"]
    $config["register"] = $pp["register"]
    $config["registerCycle"] = $pp["registerCycle"]
    $config["unregisterIfStillDownAfter"] = $pp["unregisterIfStillDownAfter"]
    $config["capabilities"] = $pp["capabilities"]
  }

$configJson = $config | ConvertTo-Json -Depth 99
$configPath = "$seleniumDir\$($pp["role"])config.json"

if ($pp["role"] -ne 'standalone') {
   $configJson | Set-Content $configPath
}

Write-Debug "Selenium configuration: $configJson"

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

$cmdParams = "$($pp["args"]) -jar ""$seleniumPath"" $options"
$cmd = "java $cmdParams"

Write-Debug "Selenium command: $cmd"

if ($pp["service"] -eq $true) {
  nssm install $name java
  nssm set $name AppDirectory $seleniumDir
  nssm set $name AppParameters $cmdParams
  if ($pp["autostart"] -eq $true) {
    nssm set $name Start SERVICE_AUTO_START
  }
  if ($pp["log"] -ne $null -and $pp["log"] -ne '') {
    nssm set $name AppStdout $pp["log"]
    nssm set $name AppStderr $pp["log"]
  }
  nssm start $name
} else {
  $cmdPath = "$seleniumDir\$($pp["role"]).cmd"

  if ($pp["log"] -ne $null -and $pp["log"] -ne '') {
     # todo logrotate files if log passed Add-Content
    $cmd | Set-Content $cmdPath
  } else {
    $cmd | Set-Content $cmdPath
  }

  $menuPrograms = [environment]::GetFolderPath([environment+specialfolder]::Programs)
  $shortcutArgs = @{
    shortcutFilePath = "$menuPrograms\Selenium\Selenium $((Get-Culture).TextInfo.ToTitleCase($pp["role"])).lnk"
    targetPath       = $cmdPath
    iconLocation     = "$toolsDir\icon.ico"
    workDirectory    = $seleniumDir
  }
  Install-ChocolateyShortcut @shortcutArgs

  if ($pp["autostart"] -eq $true) {
    $startup = "$env:SystemDrive\Users\$($pp["username"])\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
    $shortcutArgs = @{
      shortcutFilePath = "$startup\Selenium $((Get-Culture).TextInfo.ToTitleCase($pp["role"])).lnk"
      targetPath       = $cmdPath
      iconLocation     = "$toolsDir\icon.ico"
      workDirectory    = $seleniumDir
    }
    Install-ChocolateyShortcut @shortcutArgs
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

