#!/bin/bash

# Script para desplegar, verificar y exponer los servicios del laboratorio

echo "--- Verificando estado de Minikube y Docker ---"
minikube start --driver=docker --memory=2200mb --cpus 2
eval $(minikube docker-env)

# El comando de montaje de Vagrant no es necesario en una máquina física.
# Si necesitas un volumen para Nginx, deberás crear un PersistentVolumeClaim
# o usar un ConfigMap para el contenido estático.
echo "--- La carpeta compartida de Vagrant no es necesaria en este entorno. ---"

echo "--- Desplegando Nginx ---"
kubectl apply -f k8s/nginx/nginx-deployment.yaml
kubectl apply -f k8s/nginx/nginx-service.yaml

echo "--- Desplegando Prometheus ---"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update
kubectl create namespace prometheus || true
helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace prometheus \
  --set alertmanager.persistentVolume.storageClass="standard" \
  --set server.persistentVolume.storageClass="standard" \
  --set server.service.type=NodePort \
  -f k8s/monitoreo/prometheus/prometheus-values.yaml \
  --wait

echo "--- Desplegando Grafana ---"
helm repo add grafana https://grafana.github.io/helm-charts || true
helm repo update
kubectl create namespace grafana || true
helm upgrade --install grafana grafana/grafana \
  --namespace grafana \
  --set service.type=NodePort \
  --wait

echo "--- Verificando que todos los pods estén listos ---"
kubectl wait --for=condition=ready pod -l app=nginx -n default --timeout=300s
kubectl wait --for=condition=ready pod -l app=prometheus -n prometheus --timeout=300s
kubectl wait --for=condition=ready pod -l app=grafana -n grafana --timeout=300s

echo "--- Configurando túneles de reenvío de puertos ---"
HOST_IP=$(minikube ip)

# Túnel para Prometheus
PROMETHEUS_POD=$(kubectl get pods -n prometheus | grep 'prometheus-server-' | awk '{print $1}')
nohup kubectl --namespace prometheus port-forward --address 0.0.0.0 $PROMETHEUS_POD 9090:9090 > /dev/null 2>&1 &

# Túnel para Grafana
GRAFANA_POD=$(kubectl get pods -n grafana | grep 'grafana-' | awk '{print $1}')
nohup kubectl --namespace grafana port-forward --address 0.0.0.0 $GRAFANA_POD 3000:3000 > /dev/null 2>&1 &

# Túnel para Nginx
NGINX_POD=$(kubectl get pods -n default | grep 'nginx-deployment-' | awk '{print $1}')
nohup kubectl --namespace default port-forward --address 0.0.0.0 $NGINX_POD 8080:80 > /dev/null 2>&1 &

echo "--- ¡Laboratorio listo! ---"
echo "Puedes acceder a los servicios en tu máquina:"
echo "  - Prometheus: http://localhost:9090"
echo "  - Grafana:    http://localhost:3000"
echo "  - Nginx:      http://localhost:8080"