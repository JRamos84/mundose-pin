#!/bin/bash
# Script para instalar/actualizar Grafana usando Helm en Minikube

echo "Configurando repositorios y desplegando Grafana..."

helm repo add grafana https://grafana.github.io/helm-charts || true
helm repo update

# Crea el namespace "grafana" si no existe
kubectl create namespace grafana || true

helm upgrade --install grafana grafana/grafana \
  --namespace grafana \
  --set service.type=NodePort \
  --wait

echo "Verificando la instalación de Grafana..."
kubectl get pods -n grafana

# --- Detectar el puerto dinámico de Grafana ---
echo "Detectando el puerto de Grafana..."

# Obtener el puerto NodePort dinámico del servicio de Grafana
GRAFANA_NODEPORT=$(kubectl get service -n grafana grafana -o jsonpath='{.spec.ports[0].nodePort}')

echo "--------------------------------------------------------------------------------"
echo "Grafana ha sido desplegado exitosamente."
echo "Puedes acceder a la interfaz de Grafana en tu máquina local a través de:"
echo "  - http://localhost:${GRAFANA_NODEPORT}"
echo "--------------------------------------------------------------------------------"