#!/bin/bash
# Script mejorado para instalar/actualizar Prometheus

echo "Configurando repositorios y desplegando Prometheus..."

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update

kubectl create namespace prometheus || true

helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace prometheus \
  --set alertmanager.persistentVolume.storageClass="standard" \
  --set server.persistentVolume.storageClass="standard" \
  --set server.service.type=NodePort \
  -f /vagrant/k8s/monitoreo/prometheus/prometheus-values.yaml \
  --wait

echo "Verificando la instalación de Prometheus..."
kubectl get pods -n prometheus

# --- Parte mejorada para detectar el NodePort ---
echo "Detectando el puerto de Prometheus..."

# Obtener el puerto NodePort dinámico del servicio de Prometheus
PROMETHEUS_NODEPORT=$(kubectl get service -n prometheus prometheus-server -o jsonpath='{.spec.ports[0].nodePort}')

echo "--------------------------------------------------------------------------------"
echo "Prometheus ha sido desplegado exitosamente."
echo "Puedes acceder a la interfaz de Prometheus en tu máquina local a través de:"
echo "  - http://localhost:${PROMETHEUS_NODEPORT}"
echo "--------------------------------------------------------------------------------"