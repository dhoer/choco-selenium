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
# Setup Firefox Capability
##
choco install -y firefoxesr selenium-gecko-driver

##
# Setup Google Chrome Capability
##
choco install -y googlechrome --ignorechecksum
Invoke-WebRequest -Uri https://chromedriver.storage.googleapis.com/101.0.4951.41/chromedriver_linux64.zip -OutFile C:\tools\selenium\chromedriver_linux64.zip
Expand-Archive -LiteralPath C:\tools\selenium\chromedriver_linux64.zip -DestinationPath C:\tools\selenium

##
# Setup Microsoft Edge Capability
##
Invoke-WebRequest -Uri https://msedgedriver.azureedge.net/101.0.1210.39/edgedriver_win64.zip -OutFile C:\tools\selenium\edgedriver_win64.zip
Expand-Archive -LiteralPath C:\tools\selenium\edgedriver_win64.zip -DestinationPath C:\tools\selenium

##
# Setup and Configure IE Capability
##
Invoke-WebRequest -Uri https://github.com/SeleniumHQ/selenium/releases/download/selenium-4.0.0/IEDriverServer_Win32_4.0.0.zip -OutFile C:\tools\selenium\IEDriverServer_Win32_4.0.0.zip
Expand-Archive -LiteralPath C:\tools\selenium\IEDriverServer_Win32_4.0.0.zip -DestinationPath C:\tools\selenium
# $oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
# $newpath = "$oldpath;C:\tools\selenium"
# Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
# [Environment]::SetEnvironmentVariable("PATH", $Env:PATH + ";C:\tools\selenium\", [EnvironmentVariableTarget]::Machine)
Set-ExecutionPolicy Bypass; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/dhoer/selenium-iedriverserver-config/main/selenium-iedriverserver-config.ps1'))

##
# Install Selenium-Grid
##
choco pack C:\vagrant\selenium.nuspec --outputdirectory C:\vagrant
choco install -y selenium --params "'/role:hub /config:C:\\vagrant\config-hub.toml /service /autostart'" -d -s C:\vagrant --force --debug
choco install -y selenium --params "'/role:node /config:C:\\vagrant\config-node.toml /autostart'" -d -s C:\vagrant --force --debug

##
# Configure Auto-Logon
##
choco install -y autologon
autologon $env:username $env:userdomain vagrant
