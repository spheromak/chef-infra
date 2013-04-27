# -*- mode: ruby -*-
# vi: set ft=ruby :
#
Vagrant::Config.run do |config|
  config.vm.box = "opscode-ubuntu-12.04.box"
  config.vm.box_url =  "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box"
  config.ssh.forward_agent = true
  config.vm.host_name = "172.30.10.10"
  config.vm.boot_mode =  :headless
  config.vm.network  :hostonly, "172.30.10.10"
  config.vm.forward_port 443, 8443
  config.vm.forward_port  80, 8888
end
