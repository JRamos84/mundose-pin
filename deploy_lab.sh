#!/bin/bash

# Este script despliega un clúster Minikube con Nginx, Prometheus y Grafana,
# exponiendo todos los servicios a través de un Ingress.

# Detiene el script si un comando falla.
set -e

# Se define el perfil de Minikube a utilizar.
MINIKUBE_PROFILE="lab-k8s"

echo "--- Verificando y arrancando Minikube con Docker ---"
# Se inicia Minikube con un perfil para un clúster específico.
# Se verifica si el clúster ya existe para evitar reiniciarlo innecesariamente.
if ! minikube status --profile=${MINIKUBE_PROFILE} >/dev/null 2>&1; then
    echo "Iniciando Minikube..."
    minikube start --driver=docker --memory=2200mb --cpus 2 --profile=${MINIKUBE_PROFILE}
else
    echo "El clúster Minikube '${MINIKUBE_PROFILE}' ya está en ejecución."
fi
eval $(minikube docker-env -p ${MINIKUBE_PROFILE})

# Habilita el addon de Ingress en Minikube y espera a que esté listo.
echo "--- Habilitando Ingress en Minikube ---"
minikube addons enable ingress -p ${MINIKUBE_PROFILE}
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

echo "--- Creando ConfigMaps para la configuración de Nginx ---"
# Se crea un ConfigMap para el contenido HTML.
kubectl create configmap nginx-html-config --from-file=src/index.html --dry-run=client -o yaml | kubectl apply -f -
# Se crea un ConfigMap para la configuración de Nginx.
kubectl create configmap nginx-conf-config --from-file=src/nginx.conf --dry-run=client -o yaml | kubectl apply -f -

echo "--- Desplegando Nginx y su servicio (tipo ClusterIP) ---"
# Aplica el Deployment para los pods de Nginx.
kubectl apply -f k8s/nginx/nginx-deployment.yaml
# Aplica el service de Nginx de tipo ClusterIP, que será expuesto por el Ingress.
kubectl apply -f k8s/nginx/nginx-service.yaml

# --- Despliegue de herramientas de monitoreo (Prometheus y Grafana) ---

echo "--- Desplegando Prometheus ---"
# Se añade el repositorio de Helm de Prometheus.
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update
# Se crea el namespace para Prometheus si no existe.
kubectl create namespace prometheus --dry-run=client -o yaml | kubectl apply -f -
# Se actualiza o instala el chart de Prometheus usando el archivo de valores corregido.
helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace prometheus \
  -f k8s/monitoreo/prometheus/prometheus-values.yaml

echo "--- Desplegando Grafana ---"
# Se añade el repositorio de Helm de Grafana.
helm repo add grafana https://grafana.github.io/helm-charts || true
helm repo update
# Se crea el namespace para Grafana si no existe.
kubectl create namespace grafana --dry-run=client -o yaml | kubectl apply -f -
# Se actualiza o instala el chart de Grafana usando el archivo de valores corregido.
helm upgrade --install grafana grafana/grafana \
  --namespace grafana \
  -f k8s/monitoreo/grafana/grafana-values.yaml

echo "--- Verificando que todos los pods estén listos ---"
# Se espera a que el deployment de Nginx esté listo.
kubectl wait --for=condition=ready deployment/nginx-deployment -n default --timeout=300s
# Corregido: El nombre del deployment de Prometheus creado por el chart es 'prometheus-server'.
kubectl wait --for=condition=ready deployment/prometheus-server -n prometheus --timeout=300s
# Corregido: El nombre del deployment de Grafana creado por el chart es 'grafana'.
kubectl wait --for=condition=ready deployment/grafana -n grafana --timeout=300s

echo "--- Creando las reglas de Ingress para exponer los servicios ---"
# Aplica el manifiesto de Ingress después de que todos los servicios estén listos.
kubectl apply -f k8s/nginx/nginx-ingress.yaml

echo "--- Laboratorio listo con Ingress ---"
echo ""
echo "Para acceder a los servicios, primero obtén la IP de Minikube:"
echo "---"
echo "minikube ip -p ${MINIKUBE_PROFILE}"
echo "---"
echo "Luego, agrega la siguiente linea a tu archivo /etc/hosts (o C:\Windows\System32\drivers\etc\hosts):"
echo "---"
echo "<IP-DE-MINIKUBE> lab.local"
echo "---"
echo ""
echo "Finalmente, podrás acceder a los servicios en tu navegador:"
echo "  - Nginx:      http://lab.local"
echo "  - Prometheus: http://lab.local/prometheus"
echo "  - Grafana:    http://lab.local/grafana"