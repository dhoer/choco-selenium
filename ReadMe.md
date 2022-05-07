﻿# Chocolatey Selenium

[![Chocolatey](https://img.shields.io/chocolatey/dt/selenium.svg)](https://chocolatey.org/packages/Selenium)
[![AppVeyor branch](https://img.shields.io/appveyor/ci/dhoer/choco-selenium/master.svg)](https://ci.appveyor.com/project/dhoer/choco-selenium)

Installs and configures [Selenium Grid Roles](https://www.selenium.dev/documentation/grid/setting_up_your_own_grid/) using [Chocolatey Package Manager](https://chocolatey.org/).

DISCLAIMER: This package is not part of the official Selenium project.

## Selenium 4

Selenium 4 is a total rewrite and will require updating your Chocolatey scripts.
[Selenium 3](https://github.com/dhoer/choco-selenium/tree/3) is still available.

Here are the major changes:

- Configuration - Capabilities json has been replaced by [TOML configuration options](https://www.selenium.dev/documentation/grid/configuration/toml_options/).
- Logging - Logging configuration is now incorporated in the TOML configuration.
- IE Configuration - The PowerShell script to configure IE to work with [IE Driver Server](https://www.selenium.dev/documentation/ie_driver_server/) is no longer included and has been moved to its own repository: https://github.com/dhoer/selenium-iedriverserver-config.

Caveats 

- TOML - Since there is no module in PowerShell to convert TOML to a hashtable, there are limitations on what format is acceptable. There is no support for spaces around the equals sign, nor support for quotes around strings.
- NSSM - The non-sucking service manager is still used by this installer. I have concerns about the pre-release version not being updated since 2017 and that some virus scanners flag it. But Chocolatey still supports it and I don't see any better alternatives. If you have a better way, please post

## Prerequisites

- Java, Browser(s), and Browser WebDriver(s) must be installed prior to
installing selenium
- Non-Sucking Service Manager (NSSM) --pre version is required when
using `/service` option

## Quick Start

### Standalone

Install standalone server:

    choco install -y jdk10 firefox selenium-gecko-driver googlechrome selenium-chrome-driver selenium-ie-driver
    choco install -y selenium

Start the standalone server: Start > Selenium > Selenium Standalone.
Verify standalone server is available by opening Selenium Standalone
console http://localhost:4444/wd/hub/static/resource/hub.html.

### Hub

Install hub as a Windows service that will autostart on reboot:

    choco install -y nssm --pre
    choco install -y oracle17jdk
    choco install -y selenium --params "'/role:hub /service /autostart'"

Selenium hub server should be started automatically.
Verify hub server is available by opening Selenium Grid Hub console
http://localhost:4444/grid/console.

### Node

Install node as startup script that will autostart on logon and have chrome capabilities:

    $config = "C:\tools\selenium\chromeonly.toml"
    @'
    [node]
    grid-url=localhost:4444
    drivers=["chrome""]
    max-sessions=5
    '@ | New-Item $config -Type file -Force

    choco install -y oracle17jdk googlechrome selenium-chrome-driver
    choco install -y selenium --params "'/role:node /config:$config /autostart'"

Start the node server: Start > Selenium > Selenium Node.
Verify node server is available by opening Selenium Grid Hub console
http://localhost:4444/grid/console and seeing the node attached.


### AutoLogon

The autostart will start the non-Windows services when you logon.  But
to make that happen automatically, you need to install the autologon
package and run `autologon <username> <domain> <password>` once to set
it up:

    choco install -y autologon
    autologon $env:username $env:userdomain password

### IE Driver Server

Internet Explorer will require
[additional configuration](https://www.selenium.dev/documentation/ie_driver_server/#required-configuration)
in order for the IE Driver Server to work. 
A [PowerShell script](https://github.com/dhoer/selenium-iedriverserver-config) 
is available to configure IE.

### Screen Resolution

If you need to set the screen resolution different from default, check
out the
[screen-resolution](https://chocolatey.org/packages/screen-resolution)
package.


## Usage

Windows service is available, but it is only recommended for the hub
role. The non-Windows service requires a logon to allow
selenium access to the GUI to drive the browser. See
[AutoLogon](https://github.com/dhoer/choco-selenium#autologon) section
for information on how to configure Windows to logon automatically.

Chocolatey will install files under `C:/tools/selenium` directory.

### Package Parameters

The following package parameters can be set:

- `/role:` - Options are `hub`, `node`, or `standalone`.
    Default: `standalone`.
- `/javaoptions:` - Additional options to pass to Java, e.g.,
    -Dwebdriver.chrome.driver=./chromedriver.exe.
    Default: `''`.
- `/service` - Add as a Windows service instead of as a startup script.
    Note that a Windows service can't drive a GUI, so it is only
    recommended for the hub role. Default: `false`.
- `/autostart` - Set Windows services to start automatically on reboot
    or set startup scripts to start on logon.  Default: `false`.
- `/config:` - File containing [component configuration](https://www.selenium.dev/documentation/grid/configuring_components/).
- `/firewallrule` - Add inbound port firewall rule.

These parameters can be passed to the installer with the use of `--params`. 
For example: `--params "'/role:node'"`.
