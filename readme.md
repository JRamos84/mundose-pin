# Entorno de Desarrollo DevOps con Nginx en Kubernetes

Este proyecto utiliza **Vagrant** para aprovisionar un entorno de desarrollo local que incluye herramientas clave de DevOps, con un enfoque en **Kubernetes** a través de **Minikube**. El objetivo es desplegar una aplicación Nginx simple usando archivos de configuración de Kubernetes (YAML) para familiarizarte con el flujo de trabajo estándar.

## 🚀 Requisitos previos

Asegúrate de tener instaladas las siguientes herramientas en tu máquina anfitriona (tu computadora):

* [**Vagrant**](https://www.vagrantup.com/downloads)
* [**VirtualBox**](https://www.virtualbox.org/wiki/Downloads)

## 📁 Estructura del proyecto

El proyecto se compone de los siguientes archivos, que debes colocar en la misma carpeta:

* `Vagrantfile`: Define la configuración de la máquina virtual (Ubuntu 22.04).
* `instalar_herramientas_devops.sh`: Un script que instala Docker, Minikube, kubectl, Helm, etc., dentro de la VM.
* `nginx-deployment.yaml`: Manifiesto de Kubernetes para crear el **Deployment** de Nginx.
* `nginx-service.yaml`: Manifiesto de Kubernetes para exponer el Deployment como un **Service NodePort**.

## ⚙️ Pasos para el despliegue

Sigue estos pasos para levantar el entorno y desplegar la aplicación Nginx.

### Paso 1: Levantar la máquina virtual

Abre una terminal en la carpeta del proyecto y ejecuta el siguiente comando. Vagrant se encargará de descargar la imagen de Ubuntu, crear la VM y ejecutar el script de instalación automáticamente. Este proceso puede tardar varios minutos la primera vez.

```bash
vagrant up
```

### Paso 2: Desplegar la aplicación Nginx

Una vez que `vagrant up` haya finalizado, conéctate a la máquina virtual a través de SSH para desplegar los manifiestos de Kubernetes.

1.  Conéctate a la VM:
    ```bash
    vagrant ssh
    ```

2.  Dentro de la VM, aplica los archivos YAML para crear el Deployment y el Service de Nginx. Vagrant monta automáticamente la carpeta del proyecto en `/vagrant`, así que puedes acceder a los archivos directamente.
    ```bash
    kubectl apply -f /vagrant/nginx-deployment.yaml
    kubectl apply -f /vagrant/nginx-service.yaml
    ```

3.  Verifica que el servicio esté corriendo:
    ```bash
    kubectl get services
    ```

### Paso 3: Obtener el puerto y acceder a Nginx

Para acceder a Nginx desde tu máquina física, necesitas obtener el puerto dinámico de Kubernetes y configurar el reenvío de puertos en Vagrant.

1.  Ejecuta el comando para obtener el puerto **NodePort** que Kubernetes asignó al servicio.
    ```bash
    NODE_PORT=$(kubectl get service nginx-service -o jsonpath='{.spec.ports[0].nodePort}')
    echo $NODE_PORT
    ```
    Guarda el número que se muestra en la terminal.

2.  Sal de la sesión SSH:
    ```bash
    exit
    ```

3.  **Edita el `Vagrantfile`** en tu máquina anfitriona para añadir la siguiente línea de reenvío de puerto. Reemplaza `TU_PUERTO` con el número que obtuviste.

    ```ruby
    config.vm.network "forwarded_port", guest: TU_PUERTO, host: 8080
    ```

4.  **Recarga la máquina virtual** para que Vagrant aplique el nuevo reenvío. Usa `--no-provision` para evitar reinstalar todo de nuevo.
    ```bash
    vagrant reload --no-provision
    ```

5.  Una vez que la recarga termine, abre tu navegador y visita la siguiente dirección:

    ```
    http://localhost:8080
    ```
    Deberías ver la página de bienvenida de Nginx.

## 🧹 Limpieza del entorno

Cuando termines de usar el entorno, puedes apagar y eliminar completamente la máquina virtual y todos sus recursos con un solo comando:

```bash
vagrant destroy
