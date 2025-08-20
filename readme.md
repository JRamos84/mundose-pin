# Laboratorio de Monitoreo en Kubernetes con Nginx, Prometheus y Grafana

Este repositorio contiene todos los archivos de configuración y scripts necesarios para desplegar un stack de monitoreo junto con una aplicación de ejemplo (Nginx) en un clúster local de Kubernetes utilizando **Minikube**.  
El objetivo es crear un entorno de laboratorio robusto para explorar la **observabilidad**, la recolección de métricas y la visualización de datos en Kubernetes.

---

## 🚀 Arquitectura Final

El laboratorio despliega los siguientes componentes, cada uno en su propio namespace:

- **Minikube** → Clúster local de Kubernetes de un solo nodo.  
- **Ingress NGINX** → Entrada principal al clúster, enruta el tráfico basado en subdominios.  
- **Nginx (App de Ejemplo)** → Servidor web simple con métricas expuestas para Prometheus.  
- **Prometheus** → Sistema de monitoreo y alertas, instalado vía Helm en `namespace prometheus`.  
- **Grafana** → Plataforma de visualización instalada vía Helm en `namespace grafana`.  

Acceso a servicios:

- `http://lab.local` → Nginx  
- `http://prometheus.lab.local` → Prometheus UI  
- `http://grafana.lab.local` → Grafana UI  

---

## 📋 Prerrequisitos

Antes de comenzar, asegúrate de tener instaladas estas herramientas:

- [Docker](https://docs.docker.com/get-docker/)  
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)  
- [kubectl](https://kubernetes.io/docs/tasks/tools/)  
- [Helm](https://helm.sh/docs/intro/install/)  

---

## 📂 Estructura del Repositorio

```
.
├── deploy_lab.sh                  # Script para automatizar el despliegue
├── k8s/
│   ├── monitoreo/
│   │   ├── grafana/
│   │   │   ├── grafana-values.yaml
│   │   │   └── ingress-grafana.yaml
│   │   └── prometheus/
│   │       ├── prometheus-values.yaml
│   │       └── ingress-prometheus.yaml
│   └── nginx/
│       ├── ingress-nginx.yaml
│       ├── nginx-deployment.yaml
│       └── nginx-service.yaml
└── src/
    ├── index.html
    └── nginx.conf
```

---

## ⚙️ Guía de Despliegue

### 1️⃣ Clonar el Repositorio
```bash
git clone https://github.com/JRamos84/mundose-pin
cd mundose-pin
```

### 2️⃣ Ejecutar el Script
```bash
bash deploy_lab.sh
```

Este script:
- Inicia Minikube (perfil `lab-k8s` con 4GB RAM y 4 CPUs).  
- Habilita el Ingress Controller.  
- Despliega Nginx, Prometheus y Grafana vía Helm.  
- Aplica las reglas de Ingress para el acceso por subdominios.  

### 3️⃣ Configurar el DNS Local (`/etc/hosts`)

Obtén la IP del clúster:
```bash
minikube ip -p lab-k8s
```

Edita tu archivo `hosts` y agrega:
```
<IP-DE-MINIKUBE> lab.local
<IP-DE-MINIKUBE> prometheus.lab.local
<IP-DE-MINIKUBE> grafana.lab.local
```

---

## 🌐 Acceso a los Servicios

- **Nginx** → [http://lab.local](http://lab.local)  
- **Prometheus** → [http://prometheus.lab.local](http://prometheus.lab.local)  
- **Grafana** → [http://grafana.lab.local](http://grafana.lab.local)  

Credenciales Grafana:
- Usuario: `admin`  
- Contraseña:  
  ```bash
  kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
  ```

---

## 🔧 Detalles Técnicos

### Monitoreo de Nginx
- `nginx.conf` expone métricas en `/nginx_status`.  
- Sidecar **nginx-prometheus-exporter** traduce métricas al formato Prometheus.  
- Anotaciones en los Pods permiten el descubrimiento automático por Prometheus.  

### Integración Grafana + Prometheus
1. En Grafana: *Connections > Data sources > Add new connection*.  
2. Selecciona **Prometheus** y usa la URL:  
   ```
   http://prometheus-server.prometheus.svc.cluster.local
   ```
3. Guarda y prueba la conexión.  
4. Importa dashboards (ejemplo: ID `12708` de la comunidad Grafana).  

---

## 🧹 Limpieza del Entorno
Cuando termines:
```bash
minikube delete --profile lab-k8s
```

---

## ✨ Autores
**Grupo 2** – Laboratorio de Monitoreo en Kubernetes
