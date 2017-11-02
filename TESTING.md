# Testing Selenium

This Chocolatey package uses
[serverspec](http://serverspec.org/) and
[selenium-webdriver](https://github.com/SeleniumHQ/selenium/wiki/Ruby-Bindings)
for integration tests. Note that this requires Ruby language to be
installed.

Contributions to this Chocolatey package will only be accepted if all
tests pass successfully.

## Set Up

Install the latest version of
[Vagrant](http://www.vagrantup.com/downloads.html) and
[VirtualBox](https://www.virtualbox.org/wiki/Downloads).

Clone the latest version from the repository:

```batch
git clone git@github.com:dhoer/choco-selenium.git
cd choco-selenium
```

## Running

Startup Vagrant Windows 2012r2 server and provision it, then reload to
start the Selenium Grid service:

```batch
vagrant up
vagrant reload
```

If provisioning and reload when ok, then Selenium Grid should be
visible from here:

```
http://localhost:4446/grid/console
```

The hub port is normally 4444, but the port was changed to 4446 to
verify that you can change the port.

## Development

By default, Vagrant shares your project directory (remember, that is
the one with the Vagrantfile) to the `C:/vagrant` directory in your
guest machine.

Note that `C:/Users/vagrant` is a different directory from the synced
`C:/vagrant` directory.

If you make changes to in the project directory, you will need to
provision again and reload in order to see those changes:

```batch
vagrant provision
vagrant reload
```

## Testing

From the guest Windows box, run Powershell as Administrator by
right-clicking Powershell icon and selecting 'Run as Administrator'.

Run serverspec and selenium-webdriver integration tests, by installing
required gems via bundler gem and executing rake:

```batch
cd C:\vagrant
gem install bundler --no-document
bundle update
rake
```
