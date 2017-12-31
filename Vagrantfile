# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "StefanScherer/windows_10"

  config.vm.network "forwarded_port", guest: 4446, host: 4446
  config.vm.network "private_network", ip: "192.168.33.33"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "Selenium-Grid"
    vb.linked_clone = true
    vb.gui = true
    vb.memory = "2048"
    vb.customize ["modifyvm", :id, "--vram", 128]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
    vb.customize ["modifyvm", :id, "--usb", "off"]
  end

  # privileged: false - https://github.com/hashicorp/vagrant/issues/9138
  config.vm.provision "shell", path: "vagrant-provision-grid.ps1", privileged: false
  config.vm.provision "shell", inline: "choco install -y ruby --version 2.4.3.1", privileged: false
  config.vm.provision "shell", inline: "gem install bundler --no-document; cd C:\\vagrant; bundle update", privileged: false
end
