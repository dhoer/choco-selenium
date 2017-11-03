# Testing Selenium

This Chocolatey package uses [serverspec](http://serverspec.org/) and
[selenium-webdriver](https://github.com/SeleniumHQ/selenium/wiki/Ruby-Bindings)
for integration tests. [Ruby language](https://www.ruby-lang.org/) is
required for integration testing and it is installed for you during
provisioning.

Contributions to this Chocolatey package will only be accepted if all
tests pass successfully.

## Set Up

Install the latest version of
[Vagrant](http://www.vagrantup.com/downloads.html) and
[VirtualBox](https://www.virtualbox.org/wiki/Downloads).

Clone the latest version from the repository:

```
git clone git@github.com:dhoer/choco-selenium.git
cd choco-selenium
```

If vagrant was updated and throws errors, the vagrant plugins might
need to be reinstalled:

```
vagrant plugin expunge --reinstall
```

## Running

Startup Vagrant Windows 2012r2 server, provision it, and then reload to
start the Selenium Grid service:

```
vagrant up
vagrant reload
```

If provisioning and reload went ok, then Selenium Grid should be
visible from here:

```
http://192.168.33.33:4446/grid/console
```

The IP address is a private network, which allows host-only access to
the machine.  This is important since the vagrant-provision-grid.ps1
script disables Windows Update (updates during Selenium testing may
cause test failures).

The hub port is normally 4444, but the port was changed to 4446 to
verify a user can change the port.

## Development

By default, Vagrant shares your project directory (remember, that is
the one with the Vagrantfile) to the `C:/vagrant` directory in your
guest machine.

Note that `C:/Users/vagrant` is a different directory from the synced
`C:/vagrant` directory.

If you make changes in the project directory, you will need to
provision again and reload in order to see those changes:

```
vagrant provision
vagrant reload
```

## Testing

From the guest Windows box, run Powershell as Administrator by
right-clicking Powershell icon and selecting 'Run as Administrator'.

Run serverspec and selenium-webdriver integration tests, by installing
required gems via bundler gem and executing rake:

```
cd C:\vagrant
gem install bundler --no-document
bundle update
rake
```
