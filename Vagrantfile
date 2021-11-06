# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "StefanScherer/windows_11"

  config.vm.network "forwarded_port", guest: 4446, host: 4446

  config.vm.provider "virtualbox" do |vb|
    vb.name = "Selenium-Grid"
    vb.linked_clone = true
    vb.gui = true
    vb.memory = "2048"
  end

  config.vm.provision "selenium-grid", type: "shell", path: "selenium-grid.ps1"
  config.vm.provision "ie-configuration", type: "shell", path: "ie-configuration.ps1"
  config.vm.provision "ruby", type: "shell", inline: "choco install -y ruby --version 3.0.2.1"
  config.vm.provision "bundler", type: "shell", inline: "gem install bundler --no-document; cd C:\\vagrant; bundle update"
end
