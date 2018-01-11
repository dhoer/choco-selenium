# Testing Selenium

This Chocolatey package uses [serverspec](http://serverspec.org/) and
[selenium-webdriver](https://github.com/SeleniumHQ/selenium/wiki/Ruby-Bindings)
for acceptance tests. [Ruby language](https://www.ruby-lang.org/) is
required for acceptance testing and it is installed for you during
provisioning.  Maven tests are also available, but Maven is not
installed during provisioning.

Contributions to this Chocolatey package will only be accepted if all
Ruby tests pass successfully.

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

Startup Vagrant Windows 10, provision it (provision will
occur automatically on first run), and then reload to
start the Selenium Grid service:

```
vagrant up
vagrant reload
```

If provisioning and reload went ok, then Selenium Grid should be
visible from here: http://localhost:4446/grid/console.

The hub port is normally 4444, but the port was changed to 4446 to
verify a user can change the port.

Note that selenium-grid.ps1 script disables Windows Update, Windows
Defender, and Action Center because these can cause Selenium test
failures.

## Development

By default, Vagrant shares your project directory (that is the one with
the Vagrantfile) with the `C:/vagrant` directory in your guest machine.

Note that `C:/Users/vagrant` is a different directory than the synced
`C:/vagrant` directory.

If you make changes in the project directory, you will need to
provision again and reload in order to see those changes:

```
vagrant provision
vagrant reload
```

## Testing

From the guest Windows box, open a PowerShell window and run Ruby
serverspec and selenium-webdriver tests via `rake`:

```
cd C:\vagrant
rake
```

Note that vagrant installed Ruby and Ruby Gems required for testing
during provisioning.

Maven users can execute browser tests from host machine:

```
mvn clean test
```
