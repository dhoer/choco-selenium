# Selenium

Installs selenium standalone, hub, or node roles.

The selenium-server-standalone.jar, *config.json, and *.cmd files are
located in <Get-ToolsLocation>/selenium directory.

## Prerequisites

Java, Browser(s), Browser, WebDriver(s) must be installed prior to
installation of selenium.

## Dependencies

This package depends on the Non-Sucking Service Manager (NSSM).

## Quick Start

### Standalone

Install standalone server to use chrome and write to a log file.

```
$capabilites = @(
  @{
    browserName      = "firefox"
    maxInstances     = 5
    seleniumProtocol = "WebDriver"
  }
)
choco install -y nssm --pre
choco install -y jdk8 firefox selenium-gecko-driver
choco install -y selenium --params "'/capabilities:$capabilities /log:""C:/tools/selenium/log/selenium-standalone.log""'"
```

```
choco install -y selenium --params "'/capabilities:$capabilities /log:""C:/tools/selenium/log/selenium-standalone.log""'"
```

Start the standalone server Start > Selenium > Selenium Standalone.
Verify standalone server is available by opening http://localhost:4444/ and navigating to Selenium Standalone console.

### Hub

Install hub as a Windows service that will autostart on reboot

```
choco install -y nssm --pre
choco install -y jdk8
choco install -y selenium --params "'/role:hub /service /autostart'"
```

Selenium hub server should be started automatically.
Verify hub server is available by opening http://localhost:4444/ and navigating to Selenium Grid Hub console.

### Node

Install node as a startup script that will autostart on logon

```
$capabilites = @(
  @{
    browserName      = "chrome"
    maxInstances     = 5
    seleniumProtocol = "WebDriver"
  }
)
choco install -y nssm --pre
choco install -y jdk8 googlechrome selenium-chrome-driver
choco install -y selenium --params "'/role:node /hub:http://localhost:4444 /autostart /capabilities:$capabilities'"
```

## Usage

### Package Parameters

The following package parameters can be set:

#### General

These parameters are available on all roles:

- `/role` - Options are `hub`, `node`, or `standalone`.
    Default: `standalone`.
- `/log` - The log filename to use for logging. If omitted, will log
    to STDOUT. Default `''`.
- `/args` - Additional arguments to pass to Java, e.g., -Xms2G -Xmx2G.
    Default: `''`.
- `/debug` - Enables LogLevel.FINE. Default: `false`.
- `/service` - Add as a Windows service instead of as a startup script.
    Note that a Windows service can't drive a GUI, so it is recommend
    for hub role and standalone/node roles using headless browsers.
    Default: `false`.
- `/autostart` - Set Windows services to start automatically on reboot
    or set startup scripts to start on logon.  Default: `false`.
- `/username` - Startup script require a username to autostart on logon.
    If omitted, will default to current user. Default `''`.

#### Standalone

- `/browserTimeout` - In seconds : number of seconds a browser session
    is allowed to hang while a WebDriver command is running (example:
    driver.get(url)). If the timeout is reached while a WebDriver
    command is still processing, the session will quit. Minimum value
    is 60. An unspecified, zero, or negative value means wait
    indefinitely. Default: `0`.
- `/enablePassThrough` - Default: `true`.
- `/port` - The port number the server will use. Default: `4444`.
- `/timeout` - In seconds : Specifies the timeout before the server
    automatically kills a session that hasn't had any activity in the
    last X seconds. The test slot will then be released for another
    test to use. This is typically used to take care of client crashes.
    For grid hub/node roles, cleanUpCycle must also be set.
    Default: `1800`.

#### Hub

- `/browserTimeout` - In seconds : number of seconds a browser session
    is allowed to hang while a WebDriver command is running (example:
    driver.get(url)). If the timeout is reached while a WebDriver
    command is still processing, the session will quit. Minimum value
    is 60. An unspecified, zero, or negative value means wait
    indefinitely. Default: `0`.
- `/capabilityMatcher` -
    Default: `org.openqa.grid.internal.utils.DefaultCapabilityMatcher`.
- `/cleanUpCycle` - In ms : specifies how often the hub will poll
    running proxies for timed-out (i.e. hung) threads. Must also
    specify "timeout" option. Default: `5000`.
- `/newSessionWaitTimeout` - Default: `-1`.
- `/port` - The port number the server will use. Default: `4444`.
- `/servlets` - List of default (hub or node) servlets to enable.
    Advanced use cases only. Specify multiple servlets:
    `tld.company.ServletA,tld.company.ServletB`. The servlet must exist
    in the path: /grid/admin/ServletA /grid/admin/ServletB
    Default: `@()`.
- `/throwOnCapabilityNotPresent` - Default: `true`.
- `/timeout` - In seconds : Specifies the timeout before the server
    automatically kills a session that hasn't had any activity in the
    last X seconds. The test slot will then be released for another
    test to use. This is typically used to take care of client crashes.
    For grid hub/node roles, cleanUpCycle must also be set.
    Default: `1800`.
- `/withoutServlets` - List of default (hub or node) servlets to
    disable. Advanced use cases only. Not all default servlets can be
    disabled. Specify multiple servlets:
    `[tld.company.ServletA,tld.company.ServletB]`. Default: `@()`.

#### Node

- `/capabilites` - The capabilities of browser supported.
- `/hub` - The url that will be used to post the registration request.
    This option takes precedence over -hubHost and -hubPort options.
    Default: `http://localhost:4444`.
- `/downPollingLimit` - Node is marked as "down" if the node hasn't
    responded after the number of checks specified in
    `[downPollingLimit]`. Default: `2`.
- `/maxSession` - Max number of tests that can run at the same
    time on the node, irrespective of the browser used. Default: `5`.
- `/nodePolling` - In ms : specifies how often the hub will poll to see
    if the node is still responding. Default: `5000`.
- `/nodeStatusCheckTimeout` - In ms : connection/socket timeout, used
    for node "nodePolling" check. Default: `5000`.
- `/port` - The port number the server will use. Default: `5555`.
- `/proxy` - The class used to represent the node proxy.
    Default: `org.openqa.grid.selenium.proxy.DefaultRemoteProxy`
- `/register` - If specified, node will attempt to re-register itself
    automatically with its known grid hub if the hub becomes
    unavailable. Default: `true`.
- `/registerCycle` - In ms : specifies how often the node will try to
    register itself again. Allows administrator to restart the hub
    without restarting (or risk orphaning) registered nodes. Must be
    specified with the "-register" option. Default: `5000`.
- `/servlets` - List of default (hub or node) servlets to enable.
    Advanced use cases only. Specify multiple servlets:
    `[tld.company.ServletA,tld.company.ServletB]`. The servlet must
    exist in the path: /grid/admin/ServletA /grid/admin/ServletB.
    Default: `@()`.
- `/timeout` - In seconds : Specifies the timeout before the server
    automatically kills a session that hasn't had any activity in the
    last X seconds. The test slot will then be released for another test
    to use. This is typically used to take care of client crashes. For
    grid hub/node roles, cleanUpCycle must also be set. Default: `1800`.
- `/unregisterIfStillDownAfter` - In ms : if the node remains down for
    more than `unregisterIfStillDownAfter` ms, it will stop
    attempting to re-register from the hub. Default: `60000`.
- `/withoutServlets` - List of default (hub or node) servlets to
    disable. Advanced use cases only. Not all default servlets can be
    disabled. Specify multiple servlets:
    `@(tld.company.ServletA,tld.company.ServletB)`.
    Default: `@()`.

These parameters can be passed to the installer with the use of `--params`.
For example: `--params "'/role:node /hub:http://localhost:4444'"`.
