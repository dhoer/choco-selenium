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
$pp            = Get-PackageParameters

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
if ($pp["autostart"] -eq $null -or $pp["autostart"] -eq '') { $pp["autostart"] = $true }

If (!(Test-Path $seleniumDir)) {
  New-Item $seleniumDir -ItemType directory
}

# https://chocolatey.org/docs/helpers-get-chocolatey-web-file
Get-ChocolateyWebFile $packageName $seleniumPath $url -checksum $checksum -checksumType $checksumType

Write-Host -ForegroundColor Green Added selenium-server-standalone.jar to $seleniumDir

$menuPrograms = [environment]::GetFolderPath([environment+specialfolder]::Programs)

$config = Get-SeleniumConfig($pp) | ConvertTo-Json -Depth 10

Write-Debug "This would be the $($pp["role"]) configuration: $config"

$configPath = "$seleniumDir/$($pp["role"]).json"
$config | Set-Content $configPath

$servicename = "Selenium$((Get-Culture).TextInfo.ToTitleCase($pp["role"]))"

nssm install "$servicename" java -jar "$seleniumPath" -role $pp["role"] $(Get-SeleniumConfigSwitch($pp)) "$configPath" $pp['args']

if ($pp["logdir"] -ne $null -and $pp["logdir"] -ne '') {
  If (!(Test-Path $pp["logdir"])) {
    New-Item $pp["logdir"] -ItemType directory
  }
  nssm set $servicename AppStdout "$($pp["logdir"])/$($pp["role"]).out"
  nssm set $servicename AppStderr "$($pp["logdir"])/$($pp["role"]).err"
  nssm set $servicename AppStdoutCreationDisposition 4
  nssm set $servicename AppStderrCreationDisposition 4
  nssm set $servicename AppRotateFiles 1
  nssm set $servicename AppRotateOnline 0
  nssm set $servicename AppRotateSeconds 86400
  nssm set $servicename AppRotateBytes 1048576
}

if ($pp["autostart"] -eq $true) {
  nssm set $servicename Start SERVICE_AUTO_START
}

if ($pp["role"] -ne 'hub') {
  nssm reset "$servicename" ObjectName
  nssm set "$servicename" Type SERVICE_INTERACTIVE_PROCESS
}

# open windows firewall
if (-Not (netsh advfirewall firewall show rule name="$servicename" > $null)) {
  netsh advfirewall firewall add rule name="$servicename" protocol=TCP dir=in profile=any localport=$($pp["port"]) remoteip=any localip=any action=allow
}
