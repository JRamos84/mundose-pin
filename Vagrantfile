# Vagrantfile para monitorear Nginx con Prometheus y Grafana

Vagrant.configure("2") do |config|
  # Usa Ubuntu 22.04 como la base
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "nginx-monitoring-vm"
  
  # Reenvío de puertos para acceder a las herramientas desde tu máquina física
  config.vm.network "forwarded_port", guest: 9090, host: 9090  # Prometheus
  config.vm.network "forwarded_port", guest: 3000, host: 3000  # Grafana
  config.vm.network "forwarded_port", guest: 80, host: 80      # Nginx
  
  # Configurar recursos de la VM
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 1
  end
  
  # Script de aprovisionamiento
  config.vm.provision "shell", inline: <<-SHELL
    # Actualizar e instalar paquetes necesarios
    sudo apt-get update -y
    sudo apt-get install -y docker.io docker-compose wget

    # Instalar Nginx y el exporter de Nginx
    echo "Instalando Nginx y Nginx Exporter..."
    sudo docker run --name nginx_exporter -d -p 9113:9113 nginx/nginx-prometheus-exporter:latest
    sudo docker run --name nginx -d -p 80:80 nginx:latest

    # Instalar Prometheus
    echo "Instalando Prometheus..."
    wget https://github.com/prometheus/prometheus/releases/download/v2.53.1/prometheus-2.53.1.linux-amd64.tar.gz
    tar -xvf prometheus-2.53.1.linux-amd64.tar.gz
    sudo mv prometheus-2.53.1.linux-amd64/ prometheus
    
    # Instalar Grafana
    echo "Instalando Grafana..."
    wget https://dl.grafana.com/oss/release/grafana-11.1.3.linux-amd64.tar.gz
    tar -zxvf grafana-11.1.3.linux-amd64.tar.gz 
    sudo mv grafana-11.1.3/ grafana

  SHELL
  
end
