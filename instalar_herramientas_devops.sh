#!/bin/bash

echo "Iniciando la instalación de herramientas DevOps locales con Kubernetes..."

# kubectl: La herramienta universal para interactuar con clústeres de Kubernetes
echo "Instalando kubectl"
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.26.2/2023-03-17/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl # Mover a un PATH global
export PATH=$PATH:/usr/local/bin
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc # Recargar PATH
kubectl version --client

# eksctl: Para aprender sus comandos, aunque no interactuará con AWS real
echo "Instalando eksctl (para simular interacción con EKS localmente)"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
export PATH=$PATH:/usr/local/bin
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc # Recargar PATH
eksctl version

# Docker: Necesario para Minikube y para construir/ejecutar contenedores
echo "Instalando Docker"
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker vagrant
sudo systemctl enable docker.service
sudo systemctl start docker.service

# Minikube: Para ejecutar un clúster de Kubernetes local
echo "Instalando Minikube"
# Asegúrate de que curl esté instalado
sudo apt-get install -y curl
# Descargar el binario de Minikube
curl -Lo minikube https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
export PATH=$PATH:/usr/local/bin
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc # Recargar PATH
minikube version

# Helm: Gestor de paquetes para Kubernetes
echo "Instalando Helm"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Terraform: Infraestructura como código
echo "Instalando Terraform"

# --- INICIO DE LA SECCIÓN DE TERRAFORM (Método de descarga de binario, ¡probablemente el más fiable aquí!) ---
# Asegúrate de que 'jq' y 'unzip' estén instalados (si no lo están ya por otras partes del script)
sudo apt-get update # Necesario para asegurar que las listas de paquetes estén actualizadas
sudo apt-get install -y jq unzip curl # Instalar jq, unzip y curl AHORA por si acaso

# Obtener la última versión de Terraform desde la API de HashiCorp (más robusto)
TERRAFORM_VERSION=$(curl -s "https://checkpoint-api.hashicorp.com/v1/check/terraform" | jq -r .current_version)
echo "Descargando Terraform versión: $TERRAFORM_VERSION"

# Construir el nombre del archivo y la URL de descarga
TERRAFORM_FILENAME="terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_FILENAME}"

echo "URL de descarga de Terraform: $TERRAFORM_URL"
curl -LO "$TERRAFORM_URL"

# Descomprimir el archivo
unzip "$TERRAFORM_FILENAME"

# Mover el binario al PATH global
sudo mv terraform /usr/local/bin/

# Limpiar el archivo zip
rm "$TERRAFORM_FILENAME"

# Verificar la instalación
terraform version

echo "Terraform instalado exitosamente via descarga de binario."
# --- FIN DE LA SECCIÓN DE TERRAFORM ---

echo "¡Instalación de herramientas DevOps locales completa!"
echo "Para iniciar Minikube después de conectarte vía SSH, ejecuta: minikube start --driver=docker"
echo "Recuerda que para que el usuario 'vagrant' pueda ejecutar 'docker' y 'minikube' sin sudo,"
echo "deberás cerrar sesión de SSH y volver a conectarte después de la primera instalación."