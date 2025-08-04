Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "nginx-monitoring-vm"
  
  # Reenvío de puertos
  config.vm.network "forwarded_port", guest: 9090, host: 9090
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 30329, host: 8080
  # Este puerto NodePort se configurará automáticamente
  # Dejamos un placeholder, o lo omitimos y lo agregamos después
  
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "3072"
    vb.cpus = 2
  end

  # Provisión para instalar las herramientas
  config.vm.provision "shell", path: "instalar_herramientas_devops.sh"


end