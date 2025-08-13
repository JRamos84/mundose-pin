#!/bin/bash

# Script para desplegar, verificar y exponer los servicios del laboratorio

echo "--- Verificando estado de Minikube y Docker ---"
minikube start --driver=docker --memory=2200mb --cpus 2
eval $(minikube docker-env)

# El comando de montaje de Vagrant no es necesario en una máquina física.
#echo "--- La carpeta compartida de Vagrant no es necesaria en este entorno. ---"

# --- CREACIÓN DE CONFIGMAPS ---
# Esto creará un ConfigMap con el contenido de tu archivo src/index.html.
echo "--- Creando ConfigMap para el contenido HTML de Nginx ---"
kubectl create configmap nginx-html-config --from-file=src/index.html --dry-run=client -o yaml | kubectl apply -f -

# Esto creará un ConfigMap con el script de inicio para Nginx.
echo "--- Creando ConfigMap para el script de inicio de Nginx ---"
kubectl create configmap nginx-entrypoint --from-file=src/nginx-entrypoint.sh --dry-run=client -o yaml | kubectl apply -f -

echo "--- Desplegando Nginx ---"
kubectl apply -f k8s/nginx/nginx-deployment.yaml

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
# Se espera a que los pods de cada servicio estén listos con las etiquetas correctas
kubectl wait --for=condition=ready pod -l app=nginx -n default --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus-server -n prometheus --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n grafana --timeout=300s

echo "--- Todos los pods están listos. Configurando túneles de reenvío de puertos ---"

# Se detienen todos los procesos de port-forward para evitar conflictos
echo "--- Deteniendo túneles anteriores para evitar conflictos ---"
kill $(ps aux | grep 'kubectl port-forward' | grep -v 'grep' | awk '{print $2}') || true

# Obtiene los nombres de los pods con la sintaxis corregida
PROMETHEUS_POD=$(kubectl get pods -n prometheus -l app.kubernetes.io/name=prometheus-server -o jsonpath='{.items[0].metadata.name}')
GRAFANA_POD=$(kubectl get pods -n grafana -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].metadata.name}')
NGINX_POD=$(kubectl get pods -n default -l app=nginx -o jsonpath='{.items[0].metadata.name}')

echo "--- ¡Laboratorio listo! ---"
echo "Todos los servicios están desplegados. Ahora puedes iniciar los túneles de reenvío de puertos:"
echo ""
echo "En una terminal separada, usa estos comandos para acceder a tus servicios:"
echo "---"
echo "kubectl --namespace prometheus port-forward --address 0.0.0.0 $PROMETHEUS_POD 9090:9090 &"
echo "kubectl --namespace grafana port-forward --address 0.0.0.0 $GRAFANA_POD 3000:3000 &"
echo "kubectl --namespace default port-forward --address 0.0.0.0 $NGINX_POD 8080:80 &"
echo "---"
echo ""
echo "Puedes acceder a los servicios en tu máquina:"
echo "  - Prometheus: http://localhost:9090"
echo "  - Grafana:    http://localhost:3000"
echo "  - Nginx:      http://localhost:8080"