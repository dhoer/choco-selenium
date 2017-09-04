$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir              = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageName   = $env:ChocolateyPackageName
$url           = 'https://selenium-release.storage.googleapis.com/3.5/selenium-server-standalone-3.5.3.jar'
$checksum      = '3dd4cad1d343f9d1cb1302ef1b3cec98'
$checksumType  = 'md5'
$toolsLocation = Get-ToolsLocation
$seleniumDir   = "$toolsLocation\selenium"
$seleniumPath  = "$seleniumDir\selenium-server-standalone.jar"
$pp            = Get-PackageParameters

If (!(Test-Path $seleniumDir)) {
  New-Item $seleniumDir -ItemType directory
}

# https://chocolatey.org/docs/helpers-get-chocolatey-web-file
Get-ChocolateyWebFile $packageName $url $seleniumPath -checksum $checksum -checksumType $checksumType

Write-Host -ForegroundColor Green Added selenium-server-standalone.jar to $seleniumDir

$menuPrograms = [environment]::GetFolderPath([environment+specialfolder]::Programs)

if ($pp["role"] -eq $null -or $pp["role"] -eq '') { $pp["role"] = 'standalone' }

if ($pp["username"] -eq $null -or $pp["username"] -eq '') { $pp["username"] = "$env:UserName" }

if ($pp["port"] -eq $null -or $pp["port"] -eq '') {
  if ($pp["role"] -eq 'node') { $pp["port"] = 5555 } else { $pp["port"] = 4444 }
}
if ($pp["debug"] -eq $null -or $pp["debug"] -eq '') { $pp["debug"] = $false }

if ($pp["browserTimeout"] -eq $null -or $pp["browserTimeout"] -eq '') { $pp["browserTimeout"] = 0 }
if ($pp["enablePassThrough"] -eq $null -or $pp["enablePassThrough"] -eq '') { $pp["enablePassThrough"] = $true }
if ($pp["timeout"] -eq $null -or $pp["timeout"] -eq '') { $pp["timeout"] = 1800 }

if ($pp["capabilityMatcher"] -eq $null -or $pp["capabilityMatcher"] -eq '') { $pp["capabilityMatcher"] = 'org.openqa.grid.internal.utils.DefaultCapabilityMatcher' }
if ($pp["cleanUpCycle"] -eq $null -or $pp["cleanUpCycle"] -eq '') { $pp["cleanUpCycle"] = 5000 }

if ($pp["newSessionWaitTimeout"] -eq $null -or $pp["newSessionWaitTimeout"] -eq '') { $pp["newSessionWaitTimeout"] = -1 }
if ($pp["servlets"] -eq $null -or $pp["servlets"] -eq '') { $pp["servlets"] = @() }
if ($pp["throwOnCapabilityNotPresent"] -eq $null -or $pp["throwOnCapabilityNotPresent"] -eq '') { $pp["throwOnCapabilityNotPresent"] = $true }
if ($pp["withoutServlets"] -eq $null -or $pp["withoutServlets"] -eq '') { $pp["withoutServlets"] = @() }

if ($pp["hub"] -eq $null -or $pp["hub"] -eq '') { $pp["hub"] = 'http://localhost:4444' }
if ($pp["downPollingLimit"] -eq $null -or $pp["downPollingLimit"] -eq '') { $pp["downPollingLimit"] = 2 }
if ($pp["maxSession"] -eq $null -or $pp["maxSession"] -eq '') { $pp["maxSession"] = 5 }

if ($pp["nodePolling"] -eq $null -or $pp["nodePolling"] -eq '') { $pp["nodePolling"] = 5000 }
if ($pp["nodeStatusCheckTimeout"] -eq $null -or $pp["nodeStatusCheckTimeout"] -eq '') { $pp["nodeStatusCheckTimeout"] = 5000 }

if ($pp["proxy"] -eq $null -or $pp["proxy"] -eq '') { $pp["proxy"] = 'org.openqa.grid.selenium.proxy.DefaultRemoteProxy' }
if ($pp["register"] -eq $null -or $pp["register"] -eq '') { $pp["register"] = $true }
if ($pp["registerCycle"] -eq $null -or $pp["registerCycle"] -eq '') { $pp["registerCycle"] = 5000 }
if ($pp["unregisterIfStillDownAfter"] -eq $null -or $pp["unregisterIfStillDownAfter"] -eq '') { $pp["unregisterIfStillDownAfter"] = 60000 }

if ($pp["capabilities"] -eq $null -or $pp["capabilities"] -eq '') { $pp["capabilities"] = @() }

$config = getConfig($pp) | ConvertTo-Json -Depth 10

if ($pp["log"] -ne $null -and $pp["log"] -ne '') {
  #TODO INJECT LOG PATH TO CONFIG
}
Write-Debug "This would be the $($pp["role"]) configuration: $config"

$configPath = "$seleniumDir/$($pp["role"]).json"
$config | Set-Content $configPath

$cmdPath = "$seleniumDir/$($pp["role"]).cmd"
java -jar "$seleniumPath" -role $pp["role"] $(getConfigSwitch($pp)) "$configPath" > $cmdPath

# open windows firewall
if !(netsh advfirewall firewall show rule name="$($pp["role"])" > nul) {
  netsh advfirewall firewall add rule name="$($pp["role"])" protocol=TCP dir=in profile=any localport=$pp["port"] remoteip=any localip=any action=allow
}

# to be replaced by nssm
$shortcutArgs = @{
  shortcutFilePath = "$menuPrograms\Selenium\Selenium Server $($pp["role"]).lnk"
  targetPath       = $cmdPath
  iconLocation     = "$toolsDir\icon.ico"
}
Install-ChocolateyShortcut @shortcutArgs

if ($pp["autostart"] -eq $true) {
  $shortcutArgs = @{
    shortcutFilePath = "$menuPrograms\Selenium\Selenium Server $($pp["role"]).lnk"
    targetPath       = $cmdPath
    iconLocation     = "$toolsDir\icon.ico"
  }
  Install-ChocolateyShortcut @shortcutArgs
}

function getConfigSwitch ($pp) {
  if ($pp["role"] -eq 'hub') {
    return "-hubConfig"
  } elseif ($pp["role"] -eq 'node' ) {
    return "-nodeConfig"
  } else {
    return "-standaloneConfig"
  }
}

function getConfig ($pp) {
  if ($pp["role"] -eq 'hub') {
    return  @{
      role                        = "hub"
      port                        = $pp["port"]
      newSessionWaitTimeout       = $pp["newSessionWaitTimeout"]
      capabilityMatcher           = $pp["capabilityMatcher"]
      throwOnCapabilityNotPresent = $pp["throwOnCapabilityNotPresent"]
      servcleanUpCyclelets        = $pp["cleanUpCycle"]
      browserTimeout              = $pp["browserTimeout"]
      timeout                     = $pp["timeout"]
      debug                       = $pp["debug"]
      servlets                    = $pp["servlets"]
      withoutServlets             = $pp["withoutServlets"]
    }
  } elseif ($pp["role"] -eq 'node' ) {
    return @{
      role                       = "node"
      port                       = $pp["port"]
      hub                        = $pp["hub"]
      proxy                      = $pp["proxy"]
      maxSession                 = $pp["maxSession"]
      register                   = $pp["register"]
      registerCycle              = $pp["registerCycle"]
      nodeStatusCheckTimeout     = $pp["nodeStatusCheckTimeout"]
      nodePolling                = $pp["nodePolling"]
      unregisterIfStillDownAfter = $pp["unregisterIfStillDownAfter"]
      downPollingLimit           = $pp["downPollingLimit"]
      debug                      = $pp["debug"]
      servlets                   = $pp["servlets"]
      withoutServlets            = $pp["withoutServlets"]
      capabilities               = $pp["capabilities"]
    }
  } else {
    return @{
      role              = "standalone"
      port              = $pp["port"]
      browserTimeout    = $pp["browserTimeout"]
      timeout           = $pp["timeout"]
      debug             = $pp["debug"]
      enablePassThrough = $pp["enablePassThrough"]
    }
  }
}
