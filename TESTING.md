# Testing Selenium

This Chocolatey package includes
[serverspec](http://serverspec.org/) integration tests.

Contributions to this Chocolatey package will only be accepted if all
tests pass successfully.

## Set Up

Install the latest version of
[Vagrant](http://www.vagrantup.com/downloads.html) and
[VirtualBox](https://www.virtualbox.org/wiki/Downloads).

Clone the latest version from the repository.

```bash
git clone git@github.com:dhoer/choco-selenium.git
cd choco-selenium
```

## Running

Startup Vagrant and provision it, then reload to start the Selenium
Grid service:

```bash
vagrant up
vagrant reload
```

If provisioning and reload when ok, then Selenium Grid should be
visible from here:

```
http://localhost:4444/grid/console
```

## Development

By default, Vagrant shares your project directory (remember, that is
the one with the Vagrantfile) to the C:/vagrant directory in your guest
machine.

Note that C:/Users/vagrant is a different directory from the synced
C:/vagrant directory.

If you make changes to in the project directory, you will need to force
provision to run again in order to see those changes:

```bash
vagrant up --provision
vagrant reload
```

## Testing

