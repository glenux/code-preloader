# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'debian/bookworm64'
  config.vm.box_check_update = false

  config.vm.provider 'virtualbox' do |vb|
    vb.gui = false
    vb.memory = '4096'
  end

  config.vm.provider "libvirt" do |lv|
    # lv.cpus = "2"
    lv.memory = "4096"
    # enable nested virtualization
    lv.nested = true
    lv.cpu_mode = "host-model"
  end

 # config.vm.synced_folder ".", "/vagrant", type: "nfs", mount_options: ["vers=3,tcp"]
 # config.vm.synced_folder "../../exercises", "/exercises", type: "nfs", mount_options: ["vers=3,tcp"]

  config.vm.define 'demo' do |machine|
    machine.vm.hostname = 'demo'

    machine.vm.network 'forwarded_port', guest: 8080, host: 8080, host_ip: '127.0.0.1'
    machine.vm.network 'forwarded_port', guest: 80, host: 1080, host_ip: '127.0.0.1'
  end

  config.vm.provision 'shell', path: 'misc/vagrant-provision/base.sh'
end
