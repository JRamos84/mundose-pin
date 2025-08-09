# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "nginx-monitoring-vm"
  
  # La red Host-only permite la conexión directa
  config.vm.network "private_network", ip: "192.168.56.10"
  
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "3072"
    vb.cpus = 2
    vb.gui = false
  end

  # --- CONFIGURACIÓN DE PROVISIÓN CON ANSIBLE ---
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/playbooks/provision.yml"
    ansible.limit = "all"
    ansible.extra_vars = {
      "k8s_version" => "1.26.2"
    }
  end

  # Provisión para configurar el entorno
  config.vm.provision "shell", run: "always", privileged: false, inline: <<-SHELL
    echo "Asignando permisos de ejecución al script de despliegue..."
    chmod +x /vagrant/deploy_lab.sh

    echo "La máquina virtual está lista para el despliegue."
    echo "Usa el script 'deploy_lab.sh' para iniciar Minikube y desplegar los servicios."
  SHELL
end
