# Vagrantfile for creating CentOS 7 based docker host
# intended to be controlled by docker-machine

POOL_DISK_PATH = File.expand_path("../pool.vmdk", __FILE__)
POOL_DISK_SIZE = 100 # in GB

Vagrant.configure(2) do |config|
  config.vm.box = "bento/centos-7.3"
  config.vm.network "private_network", ip: "192.168.99.100"
  config.vm.provider "virtualbox" do |v|
    v.cpus = 1
    v.memory = 1024

    # add disk for docker pool
    unless File.exists?(POOL_DISK_PATH)
      v.customize %W(
        createmedium disk
        --filename #{POOL_DISK_PATH}
        --format   vmdk
        --size     #{POOL_DISK_SIZE * 1024}
      )
    end
    # ...then attach it
    v.customize [
      "storageattach", :id
    ] + %W(
      --storagectl #{"SATA Controller"}
      --device     0
      --port       1
      --type       hdd
      --medium     #{POOL_DISK_PATH}
    )
  end

  config.vbguest.auto_update = true

  config.vm.provision "shell", run: "always", inline: "systemctl restart network.service"

  config.vm.provision "shell", inline: <<-EOS
    ls /vagrant/id_rsa || ssh-keygen -f /vagrant/id_rsa -N '' -C docker-machine
    cat /vagrant/id_rsa.pub >> ~vagrant/.ssh/authorized_keys
  EOS

  config.vm.provision "shell", inline: <<-EOS
    parted -s -a optimal /dev/sdb -- mklabel msdos mkpart primary 0% 100% set 1 lvm on
    pvcreate /dev/sdb1
    vgcreate docker /dev/sdb1
    lvcreate --wipesignatures y -n thinpool docker -l 95%VG
    lvcreate --wipesignatures y -n thinpoolmeta docker -l 1%VG
    lvconvert -y --zero n -c 512K --thinpool docker/thinpool --poolmetadata docker/thinpoolmeta
    cp /vagrant/provisioning/docker-thinpool.profile /etc/lvm/profile/
    lvchange --metadataprofile docker-thinpool docker/thinpool
    lvs -o+seg_monitor
    mkdir -p /etc/docker
    cp /vagrant/provisioning/daemon.json /etc/docker
  EOS
end
