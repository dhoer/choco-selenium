# install chocolatey
Set-ExecutionPolicy Bypass; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# install selenium dependencies
choco install -y nssm --pre
choco install -y googlechrome --ignorechecksum
choco install -y jdk8 firefoxesr selenium-gecko-driver selenium-chrome-driver selenium-ie-driver

# install selenium grid
choco pack C:\vagrant\selenium.nuspec --outputdirectory C:\vagrant
choco install -y selenium --params "'/role:hub /service /port:4446 /autostart /log'" -d -s C:\vagrant --force
choco install -y selenium --params "'/role:node /hub:http://localhost:4446 /port:5557 /autostart /log'" -d -s C:\vagrant --force

# configure auto-logon
choco install -y autologon
autologon $env:username $env:userdomain vagrant

# disable autoupdate (updates during testing may cause test failure)
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU")) {
  New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Type DWord -Value 1

# install ruby language (required for integration testing)
choco install -y ruby
