# Selenium

[![Chocolatey](https://img.shields.io/chocolatey/dt/selenium.svg)](https://chocolatey.org/packages/Selenium)
[![AppVeyor branch](https://img.shields.io/appveyor/ci/dhoer/choco-selenium/master.svg)](https://ci.appveyor.com/project/dhoer/choco-selenium)

Installs and configures selenium standalone, hub, or node server
from https://github.com/SeleniumHQ/selenium/.

A [Vagrantfile](https://github.com/dhoer/choco-selenium/blob/master/Vagrantfile)
to provision a Selenium-Grid on Windows 10 with latest browsers
and drivers for Chrome, Edge, Firefox, and IE is available. See
[TESTING.md](https://github.com/dhoer/choco-selenium/blob/master/TESTING.md)
for more information.

DISCLAIMER: This package is not part of the official Selenium project.

## Prerequisites

- Java, Browser(s), and Browser WebDriver(s) must be installed prior to
installing selenium
- Non-Sucking Service Manager (NSSM) --pre version is required when
using `/service` option

## Quick Start

### Standalone

Install standalone server to use default capabilities, port 4445, and
write to a log file:

```
choco install -y jdk8 firefox selenium-gecko-driver googlechrome selenium-chrome-driver selenium-ie-driver
choco install -y selenium --params "'/port:4445 /log'"
```

Start the standalone server: Start > Selenium > Selenium Standalone.
Verify standalone server is available by opening Selenium Standalone
console http://localhost:4445/wd/hub/static/resource/hub.html.

### Hub

Install hub as a Windows service that will autostart on reboot:

```
choco install -y nssm --pre
choco install -y jdk8
choco install -y selenium --params "'/role:hub /service /autostart'"
```

Selenium hub server should be started automatically.
Verify hub server is available by opening Selenium Grid Hub console
http://localhost:4444/grid/console.

### Node

Install node as startup script that will autostart on logon and
support only chrome browser capabilities instead of the
[default capabilities](https://github.com/dhoer/choco-selenium/blob/master/tools/capabilities.json):

```
$capabilitiesJson = "C:\tools\selenium\chromeonlycapabilities.json"
@'
[
  {
    "browserName": "chrome",
    "maxInstances": 5,
    "version": "autoversion",
    "seleniumProtocol": "WebDriver"
  }
]
'@ | New-Item $capabilitiesJson -Type file -Force

choco install -y jdk8 googlechrome selenium-chrome-driver
choco install -y selenium --params "'/role:node /hub:http://localhost:4444 /capabilitiesJson:$capabilitiesJson /autostart'"
```

Start the node server: Start > Selenium > Selenium Node.
Verify node server is available by opening Selenium Grid Hub console
http://localhost:4444/grid/console and seeing the node attached.

Note that for Firefox, Chrome, and Internet Explorer; when capability
version is set to `"autoversion"`, the installer will attempt to
automatically determine and set the version.

### AutoLogon

The autostart will start the non-Windows services when you logon.  But
to make that happen automatically, you need to install the autologon
package and run `autologon <username> <domain> <password>` once to set
it up:

```
choco install -y autologon
autologon $env:username $env:userdomain redacted
```

### IE Driver

Internet Explorer will require
[additional configuration](https://github.com/SeleniumHQ/selenium/wiki/InternetExplorerDriver#required-configuration)
in order for the IE Driver to work. A PowerShell script
[ie-configuration.ps1](https://github.com/dhoer/choco-selenium/blob/master/ie-configuration.ps1)
is available to configure IE. This script has been tested on
Windows 2012R2 Server, Windows 2016 Server, and Windows 10.

## Usage

Windows service is available, but it is only recommended for the hub
role. The non-Windows service requires a logon to allow
selenium access to the GUI to drive the browser. See
[AutoLogon](https://github.com/dhoer/choco-selenium#autologon) section
for information on how to configure Windows to logon automatically.

The files installed or generated (selenium-server-standalone.jar,
*capabilites.json, *config.json, *.cmd, and *.log) are typically
located  in the `C:/tools/selenium` directory.

A firewall rule is automatically created to allow traffic to the
hub or node service port.

### Package Parameters

The following package parameters can be set:

#### General

These parameters are available on all roles:

- `/role:` - Options are `hub`, `node`, or `standalone`.
    Default: `standalone`.
- `/log` - Log to `<Get-ToolsLocation>\selenium\<role>.log`
    instead of to STDOUT. Default `false`.
- `/javaoptions:` - Additional options to pass to Java, e.g.,
    -Dwebdriver.chrome.driver=./chromedriver.exe.
    Default: `''`.
- `/debug` - Enables LogLevel.FINE. Default: `false`.
- `/service` - Add as a Windows service instead of as a startup script.
    Note that a Windows service can't drive a GUI, so it is only
    recommended for the hub role. Default: `false`.
- `/autostart` - Set Windows services to start automatically on reboot
    or set startup scripts to start on logon.  Default: `false`.

#### Standalone

- `/browserTimeout:` - In seconds : number of seconds a browser session
    is allowed to hang while a WebDriver command is running (example:
    driver.get(url)). If the timeout is reached while a WebDriver
    command is still processing, the session will quit. Minimum value
    is 60. An unspecified, zero, or negative value means wait
    indefinitely. Default: `0`.
- `/enablePassThrough` - Default: `true`.
- `/port:` - The port number the server will use. Default: `4444`.
- `/timeout:` - In seconds : Specifies the timeout before the server
    automatically kills a session that hasn't had any activity in the
    last X seconds. The test slot will then be released for another
    test to use. This is typically used to take care of client crashes.
    For grid hub/node roles, cleanUpCycle must also be set.
    Default: `1800`.

#### Hub

- `/browserTimeout:` - In seconds : number of seconds a browser session
    is allowed to hang while a WebDriver command is running (example:
    driver.get(url)). If the timeout is reached while a WebDriver
    command is still processing, the session will quit. Minimum value
    is 60. An unspecified, zero, or negative value means wait
    indefinitely. Default: `0`.
- `/capabilityMatcher:` -
    Default: `org.openqa.grid.internal.utils.DefaultCapabilityMatcher`.
- `/cleanUpCycle:` - In ms : specifies how often the hub will poll
    running proxies for timed-out (i.e. hung) threads. Must also
    specify "timeout" option. Default: `5000`.
- `/newSessionWaitTimeout:` - Default: `-1`.
- `/port:` - The port number the server will use. Default: `4444`.
- `/servlets:` - List of default (hub or node) servlets to enable.
    Advanced use cases only. Specify multiple servlets:
    `tld.company.ServletA,tld.company.ServletB`. The servlet must exist
    in the path: /grid/admin/ServletA /grid/admin/ServletB
    Default: `@()`.
- `/throwOnCapabilityNotPresent` - Default: `true`.
- `/timeout:` - In seconds : Specifies the timeout before the server
    automatically kills a session that hasn't had any activity in the
    last X seconds. The test slot will then be released for another
    test to use. This is typically used to take care of client crashes.
    For grid hub/node roles, cleanUpCycle must also be set.
    Default: `1800`.
- `/withoutServlets:` - List of default (hub or node) servlets to
    disable. Advanced use cases only. Not all default servlets can be
    disabled. Specify multiple servlets:
    `[tld.company.ServletA,tld.company.ServletB]`. Default: `@()`.

#### Node

- `/capabilitiesJson:` - The JSON file containing capabilities. A
    [capabilities.json](https://github.com/dhoer/choco-selenium/blob/master/tools/capabilities.json)
    is provided by default. For Chrome, Edge, Firefox, and Internet
    Explorer; when version is set to `"autoversion"`, the installer
    will attempt to automatically determine and set the version.
    Default: `'<Get-ToolsLocation>\selenium\capabilities.json'`.
- `/hub:` - The url that will be used to post the registration request.
    This option takes precedence over -hubHost and -hubPort options.
    Default: `http://localhost:4444`.
- `/downPollingLimit:` - Node is marked as "down" if the node hasn't
    responded after the number of checks specified. Default: `2`.
- `/maxSession:` - Max number of tests that can run at the same
    time on the node, irrespective of the browser used. Default: `5`.
- `/nodePolling:` - In ms : specifies how often the hub will poll to see
    if the node is still responding. Default: `5000`.
- `/nodeStatusCheckTimeout:` - In ms : connection/socket timeout, used
    for node "nodePolling" check. Default: `5000`.
- `/port:` - The port number the server will use. Default: `5555`.
- `/proxy:` - The class used to represent the node proxy.
    Default: `org.openqa.grid.selenium.proxy.DefaultRemoteProxy`
- `/register` - If specified, node will attempt to re-register itself
    automatically with its known grid hub if the hub becomes
    unavailable. Default: `true`.
- `/registerCycle:` - In ms : specifies how often the node will try to
    register itself again. Allows administrator to restart the hub
    without restarting (or risk orphaning) registered nodes. Must be
    specified with the "-register" option. Default: `5000`.
- `/servlets:` - List of default (hub or node) servlets to enable.
    Advanced use cases only. Specify multiple servlets:
    `[tld.company.ServletA,tld.company.ServletB]`. The servlet must
    exist in the path: /grid/admin/ServletA /grid/admin/ServletB.
    Default: `@()`.
- `/timeout:` - In seconds : Specifies the timeout before the server
    automatically kills a session that hasn't had any activity in the
    last X seconds. The test slot will then be released for another test
    to use. This is typically used to take care of client crashes. For
    grid hub/node roles, cleanUpCycle must also be set. Default: `1800`.
- `/unregisterIfStillDownAfter` - In ms : if the node remains down for
    more than `unregisterIfStillDownAfter` ms, it will stop
    attempting to re-register from the hub. Default: `60000`.
- `/withoutServlets:` - List of default (hub or node) servlets to
    disable. Advanced use cases only. Not all default servlets can be
    disabled. Specify multiple servlets:
    `@(tld.company.ServletA,tld.company.ServletB)`.
    Default: `@()`.

These parameters can be passed to the installer with the use of
`--params`. For example:
`--params "'/role:node /hub:http://localhost:4444'"`.
