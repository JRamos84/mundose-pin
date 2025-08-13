#!/bin/bash

# Script para desplegar, verificar y exponer los servicios usando Ingress

echo "--- Verificando estado de Minikube y Docker ---"
minikube start --driver=docker --memory=2200mb --cpus 2 --profile=lab-k8s
eval $(minikube docker-env -p lab-k8s)

echo "--- Habilitando Ingress en Minikube ---"
minikube addons enable ingress -p lab-k8s
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

echo "--- Creando ConfigMap para el contenido HTML de Nginx ---"
kubectl create configmap nginx-html-config --from-file=src/index.html --dry-run=client -o yaml | kubectl apply -f -

echo "--- Creando ConfigMap para la configuración de Nginx ---"
kubectl create configmap nginx-conf-config --from-file=src/nginx.conf --dry-run=client -o yaml | kubectl apply -f -

echo "--- Desplegando Nginx y su servicio (tipo ClusterIP) ---"
kubectl apply -f k8s/nginx/nginx-deployment.yaml
kubectl apply -f k8s/nginx/nginx-service.yaml

echo "--- Desplegando Prometheus ---"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update
kubectl create namespace prometheus || true
# Se elimina --wait para evitar errores de tiempo de espera
helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace prometheus \
  --set alertmanager.persistentVolume.storageClass="standard" \
  --set server.persistentVolume.storageClass="standard" \
  --set server.service.type=ClusterIP \
  -f k8s/monitoreo/prometheus/prometheus-values.yaml

echo "--- Desplegando Grafana ---"
helm repo add grafana https://grafana.github.io/helm-charts || true
helm repo update
kubectl create namespace grafana || true
# Se elimina --wait para evitar errores de tiempo de espera
helm upgrade --install grafana grafana/grafana \
  --namespace grafana \
  --set service.type=ClusterIP \
  -f k8s/monitoreo/grafana/grafana-values.yaml

echo "--- Creando las reglas de Ingress para exponer los servicios ---"
kubectl apply -f k8s/nginx/nginx-ingress.yaml

echo "--- Verificando que todos los pods estén listos ---"
kubectl wait --for=condition=ready pod -l app=nginx -n default --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus-server -n prometheus --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n grafana --timeout=300s

echo "--- Laboratorio listo con Ingress ---"
echo ""
echo "Para acceder a los servicios, primero obtén la IP de Minikube:"
echo "---"
echo "minikube ip -p lab-k8s"
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
