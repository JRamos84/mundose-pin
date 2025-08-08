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

echo "Grafana está disponible en http://localhost:3000"