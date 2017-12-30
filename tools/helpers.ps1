function Get-SeleniumConfigDefaults {
  $pp = Get-PackageParameters

  if ($pp["role"] -eq $null -or $pp["role"] -eq '') { $pp["role"] = 'standalone' }
  if ($pp["username"] -eq $null -or $pp["username"] -eq '') { $pp["username"] = "$env:UserName" }
  if ($pp["port"] -eq $null -or $pp["port"] -eq '') {
    if ($pp["role"] -eq 'node') { $pp["port"] = 5555 } else { $pp["port"] = 4444 }
  }
  if ($pp["log"] -eq $null -or $pp["log"] -eq '') { $pp["log"] = $false }
  if ($pp["service"] -eq $null -or $pp["service"] -eq '') { $pp["service"] = $false }
  if ($pp["autostart"] -eq $null -or $pp["autostart"] -eq '') { $pp["autostart"] = $false }
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

  return $pp
}

function Get-SeleniumConfig ($pp) {
  $config = @{}

  $config["role"] = $pp["role"]
  $config["port"] = $pp["port"]
  $config["browserTimeout"] = $pp["browserTimeout"]
  $config["timeout"] = $pp["timeout"]
  $config["debug"] = $pp["debug"]
  $config["enablePassThrough"] = $pp["enablePassThrough"]

  if ($pp["jettyMaxThreads"] -ne $null -and $pp["jettyMaxThreads"] -ne '') { $config["jettyMaxThreads"] = $pp["jettyMaxThreads"] }

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

  return $config
}

function Get-ChromeVersion() {
  $root   = 'HKLM:\SOFTWARE\Google\Update\Clients'
  $root64 = 'HKLM:\SOFTWARE\Wow6432Node\Google\Update\Clients'
  foreach ($r in $root,$root64) {
    $gcb = gci $r -ea 0 | ? { (gp $_.PSPath).name -eq 'Google Chrome' }
    if ($gcb) { return $gcb.GetValue('pv') }
  }
}

function Get-FirefoxVersion() {
  try {
    return iex '&"$env:ProgramFiles\Mozilla Firefox\firefox.exe" -v | more' | %{ [regex]::matches($_, "Mozilla Firefox (.*)") } | %{ $_.Groups[1].Value }
  } catch {
    try {
      return iex '&"$env:ProgramFiles(x86)\Mozilla Firefox\firefox.exe" -v | more' | %{ [regex]::matches($_, "Mozilla Firefox (.*)") } | %{ $_.Groups[1].Value }
    } catch {
      return ""
    }
  }
}

function Get-InternetExplorerVersion() {
  $reg = 'HKLM:\SOFTWARE\Microsoft\Internet Explorer'
  try {
    return (Get-ItemProperty -Path $reg -Name svcVersion).svcVersion
  } catch {
    try {
      return (Get-ItemProperty -Path $reg -Name version).version
    } catch {
      return ""
    }
  }
}

function Get-MicrosoftEdgeVersion() {
  try {
    return (Get-AppXPackage *edge*).Version
  } catch {
    return ""
  }
}

function Browser-AutoVersion($capabilities) {
  for ($i=0; $i -lt $capabilities.length; $i++) {
    if ($capabilities[$i].version -eq 'autoversion') {
      if ($capabilities[$i].browserName -eq 'firefox') {
        $capabilities[$i].version = Get-FirefoxVersion
      } elseif ($capabilities[$i].browserName -eq 'chrome') {
        $capabilities[$i].version = Get-ChromeVersion
      } elseif  ($capabilities[$i].browserName -eq 'internet explorer') {
        $capabilities[$i].version = Get-InternetExplorerVersion
      } elseif  ($capabilities[$i].browserName -eq 'MicrosoftEdge') {
        $capabilities[$i].version = Get-MicrosoftEdgeVersion
      }
    }
  }
}
