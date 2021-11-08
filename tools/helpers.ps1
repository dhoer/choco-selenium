function Get-SeleniumConfigDefaults {
  $pp = Get-PackageParameters

  if ($null -eq $pp["role"] -or '' -eq $pp["role"]) { $pp["role"] = 'standalone' }
  if ($null -eq $pp["service"] -or '' -eq $pp["service"]) { $pp["service"] = $false }
  if ($null -eq $pp["autostart"] -or '' -eq $pp["autostart"]) { $pp["autostart"] = $false }
  if ($null -eq $pp["firewallrule"] -or '' -eq $pp["firewallrule"]) { $pp["firewallrule"] = $false }
  return $pp
}

function Convert-TomlToHash($toml) {
  return Get-Content $toml | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
}

function Get-SeleniumPort {
  $port = 0
  if ($null -ne $pp["config"] -or '' -ne $pp["config"] ) {
    $configHash = Convert-TomlToHash($pp["config"])
    Write-Debug "Config hash: $configHash"
    if ($null -ne $configHash["port"] -or '' -ne $configHash["port"] ) {
      $port = $configHash["port"]
    }
  }
  if ($port -eq 0) {
    if ('node' -eq $pp["role"]) {
      $port = 5555
    } else {
      $port = 4444
    }
  }
  return $port
}
