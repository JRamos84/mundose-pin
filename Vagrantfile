# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "nginx-monitoring-vm"
  
  # Reenvío de puertos para acceder a las herramientas desde tu máquina física
  # NOTA: Los puertos NodePort son dinámicos, por lo que estos números pueden cambiar
  # si recreas el clúster. Debes verificar el puerto NodePort con `kubectl get services`.
  config.vm.network "forwarded_port", guest: 32710, host: 9090  # Prometheus
  config.vm.network "forwarded_port", guest: 30226, host: 3000  # Grafana
  
  # Opcional, para Nginx si su NodePort fuera 30452
  # config.vm.network "forwarded_port", guest: 30452, host: 8080 # Nginx
  
  # Configurar recursos de la VM
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "3072"
    vb.cpus = 2
  end

  # --- CONFIGURACIÓN DE PROVISIÓN CON ANSIBLE ---
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/playbooks/provision.yml"
    ansible.limit = "all"
    ansible.extra_vars = {
      "k8s_version" => "1.26.2"
    }
  end

  # Provisión para desplegar Nginx y el monitoreo en Minikube
  config.vm.provision "shell", run: "always", privileged: false, inline: <<-SHELL
    echo "Iniciando o configurando Minikube..."
    minikube start --driver=docker --memory=2200mb --cpus 2 || { echo "Error al iniciar Minikube. Revisa los logs."; exit 1; }
    
    echo "Minikube está listo y configurado."

    eval $(minikube docker-env)

    echo "Desplegando Nginx usando archivos YAML..."
    # Rutas corregidas para Nginx
    kubectl apply -f /vagrant/k8s/nginx/nginx-deployment.yaml
    kubectl apply -f /vagrant/k8s/nginx/nginx-service.yaml

    echo "Desplegando el stack de monitoreo (Prometheus y Grafana)..."
    # Rutas corregidas para el monitoreo
    bash /vagrant/k8s/monitoreo/prometheus/prometheus-deploy.sh
    bash /vagrant/k8s/monitoreo/grafana/grafana-deploy.sh
    
    echo "Nginx y el sistema de monitoreo han sido desplegados."
    echo "--------------------------------------------------------------------------------"
    echo "Puedes acceder a tus servicios en los siguientes puertos de tu máquina anfitriona:"
    echo "  - Prometheus: http://localhost:9090"
    echo "  - Grafana: http://localhost:3000"
    echo "  - Nginx: http://localhost:8080"
    echo "--------------------------------------------------------------------------------"
  SHELL
end