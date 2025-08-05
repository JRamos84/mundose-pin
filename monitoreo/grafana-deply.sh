#!/bin/bash
# Script para instalar/actualizar Grafana usando Helm en Minikube

echo "Configurando repositorios y desplegando Grafana..."

# Agregamos el repositorio oficial de Grafana. '|| true' evita errores si ya existe.
helm repo add grafana https://grafana.github.io/helm-charts || true

# Actualizamos los repositorios para asegurarnos de tener las últimas versiones
helm repo update

# Desplegamos Grafana. Usamos "upgrade --install" para evitar errores de reinstalación.
helm upgrade --install grafana grafana/grafana \
  --namespace prometheus \
  --wait # Espera hasta que todos los pods estén listos

# Verificamos que los pods de Grafana se estén ejecutando
echo "Verificando la instalación de Grafana..."
kubectl get pods -n prometheus

# Expone el servicio de Grafana para que sea accesible desde tu máquina anfitriona.
echo "Exponiendo el puerto de Grafana (3000)..."

# Usamos 'kubectl wait' para asegurarnos de que el deployment esté listo.
# El selector usa las etiquetas estándar de Helm para encontrar el pod de Grafana.
kubectl wait --namespace prometheus --for=condition=ready pod -l app.kubernetes.io/instance=grafana,app.kubernetes.io/name=grafana --timeout=300s

# Ahora, encontramos el nombre del pod con el selector corregido y hacemos el port-forward.
export POD_NAME=$(kubectl get pods --namespace prometheus -l "app.kubernetes.io/instance=grafana,app.kubernetes.io/name=grafana" -o jsonpath="{.items[0].metadata.name}")

if [ -z "$POD_NAME" ]; then
    echo "Error: No se encontró el pod de Grafana. Revisa las etiquetas."
else
    kubectl port-forward -n prometheus $POD_NAME 3000:3000 --address 0.0.0.0 &
echo "Grafana está disponible en http://localhost:3000"
fi
