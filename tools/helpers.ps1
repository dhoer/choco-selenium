function Get-SeleniumConfigSwitch ($pp) {
  if ($pp["role"] -eq 'hub') {
    return "-hubConfig"
  } elseif ($pp["role"] -eq 'node' ) {
    return "-nodeConfig"
  } else {
    return "-standaloneConfig"
  }
}

function Get-SeleniumConfig ($pp) {
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
