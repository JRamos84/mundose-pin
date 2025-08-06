#!/bin/bash

# Este script limpia completamente la instalación anterior de Prometheus
echo "Limpiando la instalación anterior de Prometheus..."

# Desinstala el release de Helm si existe
helm uninstall prometheus --namespace prometheus 2>/dev/null

# Elimina el namespace de Prometheus si existe
kubectl delete namespace prometheus 2>/dev/null

echo "Limpieza completada."