# install chocolatey
Set-ExecutionPolicy Bypass; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# install selenium dependencies
choco install -y nssm --pre
choco install -y jdk8
choco install -y googlechrome --ignorechecksum
choco install -y chromedriver

# install selenium grid
choco pack C:\vagrant\selenium.nuspec --outputdirectory C:\vagrant
choco install -y selenium --params "'/role:hub /autostart'" -d -s C:\vagrant --force
choco install -y selenium --params "'/role:node /hub:http://localhost:4444 /autostart'" -d -s C:\vagrant --force

# configure auto-logon
choco install -y autologon
autologon $env:username $env:userdomain vagrant

# disable autoupdate (updates during testing may cause test failure)
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU")) {
  New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Type DWord -Value 1

# start grid
Start-Process C:\tools\selenium\hub.cmd -PassThru
Start-Process C:\tools\selenium\node.cmd -PassThru