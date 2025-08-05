# Entorno de Desarrollo DevOps con Nginx en Kubernetes

Este proyecto utiliza **Vagrant** para aprovisionar un entorno de desarrollo local con las herramientas principales de DevOps, incluyendo **Kubernetes** a través de **Minikube**. El objetivo es desplegar una aplicación Nginx y un stack de monitoreo (Prometheus y Grafana) para demostrar un flujo de trabajo de desarrollo moderno y reproducible.

## 🚀 Requisitos previos

Asegúrate de tener instaladas las siguientes herramientas en tu máquina anfitriona (tu computadora):

* [**Vagrant**](https://www.vagrantup.com/downloads): Para la gestión de máquinas virtuales.

* [**VirtualBox**](https://www.virtualbox.org/wiki/Downloads): El proveedor de virtualización para Vagrant.

## 📁 Estructura del proyecto

El proyecto se compone de los siguientes archivos en su directorio principal:

* `Vagrantfile`: El archivo principal de configuración de Vagrant.

* `instalar_herramientas_devops.sh`: Script que instala todas las herramientas (Docker, Minikube, etc.) dentro de la VM.

### `nginx/`

Contiene los manifiestos de Kubernetes para la aplicación de ejemplo.

* `nginx-deployment.yaml`: Manifiesto que crea el **Deployment** de Nginx y un contenedor "sidecar" para exponer métricas a Prometheus.

* `nginx-service.yaml`: Manifiesto que expone el Deployment como un servicio `NodePort` para que sea accesible desde tu máquina anfitriona.

### `monitoreo/`

Contiene los scripts y archivos de configuración para el stack de monitoreo.

* `prometheus-deploy.sh`: Script para instalar **Prometheus** con Helm, incluyendo la configuración para que descubra las métricas de Nginx.

* `grafana-deploy.sh`: Script para instalar **Grafana** con Helm.

* `prometheus-values.yaml`: Sobreescribe la configuración de Prometheus para que descubra y recolecte las métricas de los pods.

## ⚙️ Flujo de trabajo para el despliegue

Sigue estos pasos para levantar y configurar todo el entorno.

### Paso 1: Levantar la máquina virtual e instalar las herramientas

Abre una terminal en el directorio del proyecto y ejecuta el siguiente comando. `vagrant up` descargará la imagen de Ubuntu, creará la VM y ejecutará el script de instalación automáticamente. Este proceso puede tardar varios minutos la primera vez.

```bash
vagrant up
```

### Paso 2: Desplegar Nginx y configurar el acceso

Una vez que `vagrant up` haya finalizado, conéctate a la máquina virtual a través de SSH para desplegar Nginx y luego configurar el acceso desde tu navegador.

1.  Conéctate a la VM y configura el entorno de Minikube:

    ```bash
    vagrant ssh
    minikube start
    ```

    El comando `minikube start` asegura que tu sesión de terminal se conecte correctamente al clúster de Kubernetes.

2.  Aplica los manifiestos YAML de Nginx:

    ```bash
    kubectl apply -f /vagrant/nginx/nginx-deployment.yaml
    kubectl apply -f /vagrant/nginx/nginx-service.yaml
    ```

3.  Obtén el puerto de **NodePort** asignado dinámicamente por Kubernetes:

    ```bash
    NODE_PORT=$(kubectl get service nginx-service -o jsonpath='{.spec.ports[0].nodePort}')
    echo $NODE_PORT
    ```

    Guarda el número que se muestra en la terminal (ej. `32000`). Este es el puerto en la máquina virtual que expone Nginx.

4.  Sal de la sesión SSH (`exit`).

5.  **Edita el `Vagrantfile`** en tu máquina anfitriona para añadir la línea de reenvío de puerto. Reemplaza `TU_PUERTO` con el número que obtuviste en el paso anterior.

    ```ruby
    # Añade esta línea al Vagrantfile
    config.vm.network "forwarded_port", guest: TU_PUERTO, host: 8080 # Acceso a Nginx
    ```

6.  **Recarga la máquina virtual** para que Vagrant aplique el nuevo reenvío de puertos.

    ```bash
    vagrant reload --no-provision
    ```

7.  Una vez que la recarga termine, abre tu navegador y visita:

    ```
    http://localhost:8080
    ```

    Deberías ver la página de bienvenida de Nginx.

### Paso 3: Desplegar el stack de monitoreo (Prometheus y Grafana)

1.  Conéctate nuevamente a la VM:

    ```bash
    vagrant ssh
    ```

2.  En la terminal de la VM, navega a la carpeta de monitoreo y ejecuta los scripts de despliegue.

    ```bash
    cd /vagrant/monitoreo
    bash prometheus-deploy.sh
    bash grafana-deploy.sh
    ```

    Estos scripts instalarán Prometheus y Grafana usando Helm. Cada script se ejecutará en segundo plano para que puedas seguir usando la terminal.

### Paso 4: Obtener credenciales y configurar Grafana

Para acceder a los servicios, necesitas obtener las credenciales y configurar el reenvío de puertos.

1.  **Obtén la contraseña de Grafana**: La contraseña de administrador es generada dinámicamente y almacenada en un secreto de Kubernetes.

    ```bash
    kubectl get secret --namespace prometheus grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
    ```

    Copia la contraseña que se muestra.

2.  **Obtén la IP interna de Prometheus**: Esta es la dirección IP del servicio de Prometheus dentro del clúster de Kubernetes, que Grafana usará para recolectar datos.

    ```bash
    kubectl get svc prometheus-server --namespace prometheus
    ```

    Copia la IP que se muestra en la columna `CLUSTER-IP` (ej. `10.100.135.36`).

3.  **Accede a Grafana**: Abre tu navegador y ve a `http://localhost:3000`.

    * **Usuario:** `admin`

    * **Contraseña:** La que obtuviste del secreto.
      Una vez dentro, navega a **Configuration** -> **Data Sources** -> **Prometheus** y configura la fuente de datos.

    * En el campo **URL**, introduce `http://[TU_CLUSTER_IP]:80` (usando la IP que obtuviste). El puerto `80` es el puerto de servicio que se reenvía internamente al puerto 9090 del pod de Prometheus.

    * Haz clic en **"Save & Test"** para verificar la conexión.

4.  **Importa el Dashboard de Nginx**:

    * En Grafana, ve a **Dashboards** -> **Import**.

    * Introduce el ID del dashboard `9621` en el campo de importación.

    * Haz clic en **Load** y luego en **Import**, seleccionando la fuente de datos de Prometheus.

¡Listo! Ahora tienes un entorno de desarrollo completo con monitoreo de Nginx.

## 🧹 Limpieza del entorno

Para apagar y eliminar completamente la máquina virtual y todos sus recursos, usa:

```bash
vagrant destroy
