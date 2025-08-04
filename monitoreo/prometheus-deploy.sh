#!/bin/bash
# Script para instalar/actualizar Prometheus usando Helm en Minikube

echo "Configurando repositorios y desplegando Prometheus..."

# Agregamos el repositorio oficial de Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true

# Actualizamos los repositorios para asegurarnos de tener las últimas versiones
helm repo update

# Creamos el namespace para Prometheus
kubectl create namespace prometheus || true

# Desplegamos Prometheus. Usamos "upgrade --install" para evitar errores.
helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace prometheus \
  --set alertmanager.persistentVolume.storageClass="standard" \
  --set server.persistentVolume.storageClass="standard" \
  --wait # Espera hasta que todos los pods estén listos

# Verificamos que los pods de Prometheus se estén ejecutando
echo "Verificando la instalación de Prometheus..."
kubectl get pods -n prometheus

# Expone el servicio de Prometheus para que sea accesible desde tu máquina anfitriona.
echo "Exponiendo el puerto de Prometheus (9090)..."

# Usamos 'kubectl wait' para asegurarnos de que el deployment esté listo.
kubectl wait --namespace prometheus --for=condition=ready pod -l app.kubernetes.io/instance=prometheus,app.kubernetes.io/name=prometheus --timeout=300s

# Ahora, encontramos el nombre del pod con el selector corregido y hacemos el port-forward.
export POD_NAME=$(kubectl get pods --namespace prometheus -l "app.kubernetes.io/instance=prometheus,app.kubernetes.io/name=prometheus" -o jsonpath="{.items[0].metadata.name}")

if [ -z "$POD_NAME" ]; then
    echo "Error: No se encontró el pod de Prometheus. Revisa las etiquetas."
else
    kubectl port-forward -n prometheus $POD_NAME 9090:9090 --address 0.0.0.0 &
    echo "Prometheus está disponible en http://localhost:9090"
fi
