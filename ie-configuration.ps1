##
# IE Required Configuration - https://github.com/SeleniumHQ/selenium/wiki/InternetExplorerDriver#required-configuration
##

$TimeStamp = [System.Math]::Round((Get-Date -Date ((Get-Date).ToUniversalTime()) -UFormat %s))

# disable Internet Explorer Enhanced Security Configuration (ESC) - http://support.microsoft.com/kb/933991
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}")) {
  New-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Type DWord -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}")) {
  New-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Type DWord -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_ESCZoneMap_IEHarden")) {
  New-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_ESCZoneMap_IEHarden" -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_ESCZoneMap_IEHarden" -Name "Version" -Type String -Value $TimeStamp
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_ESCZoneMap_IEHarden" -Name "StubPath" -Type String -Value 'reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v IEHarden /d 0 /t REG_DWORD /f'

# disable IE "You are about to view pages over a secure connection" prompt
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_WarnOnZoneCrossing")) {
  New-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_WarnOnZoneCrossing" -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_WarnOnZoneCrossing" -Name "Version" -Type String -Value $TimeStamp
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_WarnOnZoneCrossing" -Name "StubPath" -Type String -Value 'reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnOnZoneCrossing /d 0 /t REG_DWORD /f'

# enable protected mode for local internet zone - http://support.microsoft.com/kb/182569
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone1_2500")) {
  New-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone1_2500" -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone1_2500" -Name "Version" -Type String -Value $TimeStamp
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone1_2500" -Name "StubPath" -Type String -Value 'reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1" /v 2500 /d 0 /t REG_DWORD /f'

# enable protected mode for trusted sites zone - http://support.microsoft.com/kb/182569
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone2_2500")) {
  New-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone2_2500" -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone2_2500" -Name "Version" -Type String -Value $TimeStamp
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone2_2500" -Name "StubPath" -Type String -Value 'reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" /v 2500 /d 0 /t REG_DWORD /f'

# enable protected mode for internet zone - http://support.microsoft.com/kb/182569
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone3_2500")) {
  New-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone3_2500" -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone3_2500" -Name "Version" -Type String -Value $TimeStamp
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone3_2500" -Name "StubPath" -Type String -Value 'reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 2500 /d 0 /t REG_DWORD /f'

# enable protected mode for restricted sites zone - http://support.microsoft.com/kb/182569
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone4_2500")) {
  New-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone4_2500" -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone4_2500" -Name "Version" -Type String -Value $TimeStamp
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone4_2500" -Name "StubPath" -Type String -Value 'reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4" /v 2500 /d 0 /t REG_DWORD /f'

# enable active scripting for internet zone - http://support.microsoft.com/kb/182569
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone3_1400")) {
  New-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone3_1400" -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone3_1400" -Name "Version" -Type String -Value $TimeStamp
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zone3_1400" -Name "StubPath" -Type String -Value 'reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 1400 /d 0 /t REG_DWORD /f'

# disable IE Feature Back-Forward Cache - allows drivers to maintain a connection to IE (IE 11 only).
If (!(Test-Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BFCACHE")) {
  New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BFCACHE" -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BFCACHE" -Name "iexplore.exe" -Type DWord -Value 0

# configure IE Zoom Level to be 100%
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zoom_ZoomFactor")) {
  New-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zoom_ZoomFactor" -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zoom_ZoomFactor" -Name "Version" -Type String -Value $TimeStamp
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\IE_Zoom_ZoomFactor" -Name "StubPath" -Type String -Value 'reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\Zoom" /v ZoomFactor /d 100_000 /t REG_DWORD /f'

# disable IE First Run
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main")) {
  New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Type DWord -Value 1

# disable IE "You are about to view pages over a secure connection" prompt
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "WarnOnZoneCrossing" -Type DWord -Value 0

# allow IE Driver through Firewall
New-NetFirewallRule -DisplayName "Command line server for the IE driver" -Direction Inbound -Program "C:\tools\selenium\iedriverserver.exe" -Action Allow
