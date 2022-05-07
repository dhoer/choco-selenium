function Get-SeleniumConfigDefaults {
  $pp = Get-PackageParameters

  if ($null -eq $pp["role"] -or '' -eq $pp["role"]) { $pp["role"] = 'standalone' }
  if ($null -eq $pp["service"] -or '' -eq $pp["service"]) { $pp["service"] = $false }
  if ($null -eq $pp["autostart"] -or '' -eq $pp["autostart"]) { $pp["autostart"] = $false }
  if ($null -eq $pp["firewallrule"] -or '' -eq $pp["firewallrule"]) { $pp["firewallrule"] = $false }
  return $pp
}

function Convert-TomlToHash($file) {
  Write-Debug "Config: $file"
  $config = [ordered] @{}
  If (Test-Path $file) { 
    # Parse the lines of input file "file.ini"
    switch -Regex -File $file {

      '^\[(.+?)\]\s*$' { # section header
        $config[$Matches[1]] = [ordered] @{} # initialize nested ordered hash for section
      }

      '^\s*([^=]+)=\s*(.*)$' {  # property-value pair

        # Simple support for string and integer values.
        $key, $val = $Matches[1].Trim(), $Matches[2].Trim()
        if ($val -like '"*"') { $val = $val -replace '"' }
        else                  { $val = [int] $val }

        # Add new entry, to the most recently added ([-1]) section hashtable.
        $config[-1].Add($key, $val)
      }

    }
  }
  Write-Debug ("Hash: " + $config | Out-String)
  return $config
}

function Get-SeleniumPort {
  $port = 0
  if (-Not($null -eq $pp["config"] -or '' -eq $pp["config"])) {
    $configHash = Convert-TomlToHash($pp["config"])
    if (-Not($null -eq $configHash -or '' -eq $configHash)) {
      if (-Not($null -eq $configHash["port"] -or '' -eq $configHash["port"])) {
        $port = $configHash["port"]
      }
    }
  }
  if ($port -eq 0) {
    if ('node' -eq $pp["role"]) {
      $port = 5555
    } else {
      $port = 4444
    }
  }
  Write-Debug "Port: $port"
  return $port
}
