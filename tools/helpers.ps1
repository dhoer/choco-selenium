function Get-SeleniumConfigDefaults {
  $pp = Get-PackageParameters

  if ($null -eq $pp["role"] -or '' -eq $pp["role"]) { $pp["role"] = 'standalone' }
  if ($null -eq $pp["username"] -or '' -eq $pp["username"]) { $pp["username"] = "$env:UserName" }
  if ($null -eq $pp["service"] -or '' -eq $pp["service"]) { $pp["service"] = $false }
  if ($null -eq $pp["autostart"] -or '' -eq $pp["autostart"]) { $pp["autostart"] = $false }
  if ($null -eq $pp["config"] -or '' -eq $pp["config"] ) {
    $pp["config"] = "$seleniumDir\$($pp["role"])-config.toml"
  }
  return $pp
}

function Convert-TomlToHash($toml) {
  return Get-Content $toml | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
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
  }
  catch {
    try {
      return (Get-ItemProperty -Path $reg -Name version).version
    }
    catch {
      return ""
    }
  }
}

function Get-MicrosoftEdgeVersion() {
  try {
    return Get-AppXPackage -Name *Edge* | Foreach Version
  }
  catch {
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
