##
# Disable autoupdate - updates during testing may cause test failure
##
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU")) {
  New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Type DWord -Value 1

##
# Disable Windows Defender - defender may cause test failure (Windows 10/Windows 2016 Server or higher)
##
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender")) {
  New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Type DWord -Value 1
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -ErrorAction SilentlyContinue

##
# Disable Action Center - notifications may cause test failure (Windows 10/Windows 2016 Server or higher)
##

If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
  New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0

##
# Install Chocolatey - https://chocolatey.org
##
Set-ExecutionPolicy Bypass; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

##
# Install Selenium-Grid Dependencies
##
choco install -y nssm --pre
choco install -y oraclejdk --version 17.0.1

##
# Allow Java JDK to be called
##
New-NetFirewallRule -DisplayName "Oracle Java(TM) JDK" -Direction Inbound -Program "C:\program files\java\jdk-17.0.1\bin\java.exe" -Action Allow -Enabled True

##
# Install Google Chrome Browser Dependencies
##
choco install -y googlechrome --ignorechecksum
choco install -y selenium-chrome-driver

##
# Install Firefox Browser Dependencies
##
choco install -y firefoxesr selenium-gecko-driver


##
# Install Microsoft Edge Browser Dependencies
##
choco install -y selenium-edge-driver

##
# Install and Configure IE Browser Dependencies
##
choco install -y selenium-ie-driver
Set-ExecutionPolicy Bypass; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/dhoer/selenium-iedriverserver-config/main/selenium-iedriverserver-config.ps1'))

##
# Install Selenium-Grid
##
choco pack C:\vagrant\selenium.nuspec --outputdirectory C:\vagrant
choco install -y selenium --params "'/role:hub /config:C:\\vagrant\config-hub.toml /service /autostart'" -d -s C:\vagrant --force --debug
choco install -y selenium --params "'/role:node /config:C:\\vagrant\config-node.toml /service /autostart'" -d -s C:\vagrant --force --debug

##
# Configure Auto-Logon
##
choco install -y autologon
autologon $env:username $env:userdomain vagrant
