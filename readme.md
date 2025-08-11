# Laboratorio DevOps con Minikube

Este proyecto contiene una configuración para desplegar un entorno de monitoreo y un servidor web estático en un clúster local de Kubernetes usando **Minikube**. El propósito de este laboratorio es proporcionar un entorno de práctica listo para usar, ideal para desarrolladores y estudiantes de DevOps que quieran familiarizarse con la orquestación de contenedores y las herramientas de monitoreo más comunes.  

El laboratorio incluye los siguientes servicios:

- **Nginx:** Un servidor web que aloja una página estática simple para demostrar el despliegue de una aplicación.  
- **Prometheus:** Una potente solución de monitoreo y alerta que se encarga de recolectar métricas del clúster y de los servicios.  
- **Grafana:** Un dashboard de visualización que se integra con Prometheus para mostrar las métricas en paneles interactivos y fáciles de entender.  

La configuración está diseñada para ser flexible, permitiendo su despliegue tanto en una máquina virtual con Vagrant para un entorno aislado y controlado, como directamente en una máquina física para mayor simplicidad y eficiencia.

---

## Requisitos

Para ejecutar el laboratorio en tu máquina física, es fundamental que tengas instaladas y configuradas las siguientes herramientas en tu sistema. Cada una cumple una función específica dentro del flujo de trabajo:

- **Docker:** Actúa como el motor de contenedores que Minikube utiliza para crear y gestionar el clúster local de Kubernetes. Sin Docker, Minikube no puede funcionar con el driver de contenedores.  
- **Minikube:** Se encarga de crear un clúster de Kubernetes de un solo nodo en tu máquina local. Es la herramienta perfecta para desarrollo y pruebas, ya que simula un entorno de Kubernetes completo sin la complejidad de un clúster de producción.  
- **kubectl:** Es la herramienta de línea de comandos estándar para interactuar con los clústeres de Kubernetes. La usarás para desplegar aplicaciones (como Nginx) y para verificar el estado de los componentes del clúster.  
- **Helm:** Conocido como el gestor de paquetes de Kubernetes, simplifica el despliegue de aplicaciones complejas. Para este proyecto, Helm se utiliza para instalar y configurar Prometheus y Grafana de manera sencilla a través de sus "charts" (paquetes preconfigurados).

---

## Despliegue del laboratorio

El despliegue del entorno completo se gestiona a través del script `deploy_lab.sh`. Este script ha sido diseñado para automatizar todo el proceso, minimizando la intervención manual y asegurando que la configuración sea consistente. El script ejecuta los siguientes pasos en orden:

1. Inicia un clúster de Minikube con el driver de Docker. Este comando es idempotente, lo que significa que solo iniciará el clúster si no está en funcionamiento.  
2. Despliega los servicios de Nginx, Prometheus y Grafana utilizando los archivos de manifiesto de Kubernetes y los charts de Helm.  
3. Espera a que todos los pods estén listos y saludables antes de continuar.  
4. Configura el reenvío de puertos para exponer los servicios del clúster en tu máquina local.

---

## Instrucciones

1. Abre una terminal y navega al directorio raíz del proyecto:  
   ```
   cd /ruta/a/tu/proyecto
   ```

2. Dale permisos de ejecución al script si aún no los tiene:  
   ```
   chmod +x deploy_lab.sh
   ```

3. Ejecuta el script de despliegue:  
   ```
   ./deploy_lab.sh
   ```

Una vez que el script finalice, verás un mensaje con las URLs de acceso a los servicios en tu máquina local.

---

## Verificación de los servicios

Para asegurarte de que todo funciona correctamente después del despliegue, puedes usar estos comandos:

1. **Verificar el estado de Minikube:**  
   ```
   minikube status
   ```
   Debe mostrar que el `host`, `kubelet` y `apiserver` están en estado **Running**.

2. **Verificar el estado de los pods:**  
   ```
   kubectl get pods --all-namespaces
   ```
   Todos los pods de Nginx, Prometheus y Grafana deben estar en estado **Running** o **Completed**.

3. **Verificar el estado de los servicios:**  
   ```
   kubectl get services --all-namespaces
   ```

4. **Acceder a las aplicaciones:**
   - Nginx: [http://localhost:8080](http://localhost:8080)  
   - Prometheus: [http://localhost:9090](http://localhost:9090)  
   - Grafana: [http://localhost:3000](http://localhost:3000)  

---

## Limpiar el entorno

Para detener y liberar completamente los recursos del clúster de Minikube:  
```
minikube stop && minikube delete
```
Esto detendrá el clúster y lo eliminará por completo, borrando todos los datos asociados.

---
