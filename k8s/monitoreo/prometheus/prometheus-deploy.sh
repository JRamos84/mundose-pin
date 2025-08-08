#!/bin/bash
# Script para instalar/actualizar Prometheus usando Helm en Minikube

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

echo "Prometheus está disponible en http://localhost:9090"
