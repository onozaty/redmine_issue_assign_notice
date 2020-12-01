Vagrant.configure("2") do |config|
  config.vm.box = "onozaty/redmine-4.1"

  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.synced_folder ".", "/var/lib/redmine/plugins/redmine_issue_assign_notice", create: true, mount_options: ['dmode=755','fmode=655']

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
end
