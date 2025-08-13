#!/bin/bash

# Script para desplegar, verificar y exponer los servicios del laboratorio
# Este script utiliza un servicio de tipo LoadBalancer para Nginx.
# La exposición de los puertos requiere un paso manual.

echo "--- Verificando estado de Minikube y Docker ---"
minikube start --driver=docker --memory=2200mb --cpus 2 --profile=lab-k8s 
eval $(minikube docker-env -p lab-k8s)

echo "--- Creando ConfigMap para el contenido HTML de Nginx ---"
kubectl create configmap nginx-html-config --from-file=src/index.html --dry-run=client -o yaml | kubectl apply -f -

echo "--- Creando ConfigMap para la configuración de Nginx ---"
kubectl create configmap nginx-conf-config --from-file=src/nginx.conf --dry-run=client -o yaml | kubectl apply -f -

echo "--- Desplegando Nginx y su servicio de tipo LoadBalancer ---"
kubectl apply -f k8s/nginx/nginx-deployment.yaml


echo "--- Desplegando Prometheus ---"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update
kubectl create namespace prometheus || true
helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace prometheus \
  --set alertmanager.persistentVolume.storageClass="standard" \
  --set server.persistentVolume.storageClass="standard" \
  --set server.service.type=ClusterIP \
  -f k8s/monitoreo/prometheus/prometheus-values.yaml \
  --wait

echo "--- Desplegando Grafana ---"
helm repo add grafana https://grafana.github.io/helm-charts || true
helm repo update
kubectl create namespace grafana || true
helm upgrade --install grafana grafana/grafana \
  --namespace grafana \
  --set service.type=ClusterIP \
  --wait

echo "--- Verificando que todos los pods estén listos ---"
kubectl wait --for=condition=ready pod -l app=nginx -n default --timeout=300s
# Corregido: La etiqueta del servidor de Prometheus es 'app.kubernetes.io/name=prometheus'
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n prometheus --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n grafana --timeout=300s

echo "--- Laboratorio listo. Ahora debes configurar el acceso de forma manual ---"
echo ""
echo "Para exponer el servicio de Nginx (LoadBalancer), abre una terminal nueva y ejecuta este comando."
echo "¡DEBES DEJAR ESTE COMANDO CORRIENDO!"
echo "---"
echo "minikube tunnel -p lab-k8s"
echo "---"
echo ""
echo "Una vez que el túnel esté funcionando, obtén la IP externa del servicio de Nginx con:"
echo "---"
echo "kubectl get service nginx-service"
echo "---"
echo "Podrás acceder a los servicios en tu máquina:"
echo "  - Nginx:      http://<IP-EXTERNA-DEL-SERVICIO-NGINX>"
echo "  - Prometheus: http://<IP-EXTERNA-DEL-SERVICIO-NGINX>/prometheus"
echo "  - Grafana:    http://<IP-EXTERNA-DEL-SERVICIO-NGINX>/grafana"
