#!/bin/bash
# Script para instalar Grafana usando Helm en Minikube

echo "Configurando repositorios y desplegando Grafana..."

# Agregamos el repositorio oficial de Grafana
helm repo add grafana https://grafana.github.io/helm-charts

# Actualizamos los repositorios
helm repo update

# Desplegamos Grafana. Usamos el mismo namespace de Prometheus para mantener todo junto.
helm install grafana grafana/grafana \
  --namespace prometheus

# Verificamos que los pods de Grafana se estén ejecutando
echo "Verificando la instalación de Grafana..."
kubectl get pods -n prometheus

# Expone el servicio de Grafana en el puerto 3000
# La dirección 0.0.0.0 es necesaria para que sea accesible desde fuera de la VM.
# El puerto 3000 es el puerto por defecto de Grafana.
echo "Exponiendo el puerto de Grafana (3000)..."
kubectl port-forward -n prometheus deploy/grafana 3000:3000 --address 0.0.0.0 &
echo "Grafana está disponible en http://localhost:3000"
