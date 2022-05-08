function Get-SeleniumConfigDefaults {
  $pp = Get-PackageParameters

  if ($null -eq $pp["role"] -or '' -eq $pp["role"]) { $pp["role"] = 'standalone' }
  if ($null -eq $pp["service"] -or '' -eq $pp["service"]) { $pp["service"] = $false }
  if ($null -eq $pp["autostart"] -or '' -eq $pp["autostart"]) { $pp["autostart"] = $false }
  return $pp
}
