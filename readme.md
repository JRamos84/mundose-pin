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

```
Esto detendrá el clúster y lo eliminará por completo, borrando todos los datos asociados.

---


comandos 

Claro, hay varios comandos de kubectl que puedes usar para verificar si tus pods están desplegados correctamente. Aquí te los presento desde el más básico y común hasta otros más específicos y útiles.

1. El Comando Esencial: kubectl get pods
Este es el comando principal para listar todos los pods en el namespace (espacio de nombres) actual. Te da un resumen rápido de su estado.

Bash

kubectl get pods
Salida de ejemplo:

NAME                               READY   STATUS    RESTARTS   AGE
grafana-676d56c547-abcde           1/1     Running   0          5m
nginx-deployment-78dcf96497-fghij   1/1     Running   0          10m
nginx-deployment-78dcf96497-klmno   1/1     Running   0          10m
prometheus-server-65c6c888-pqrst    2/2     Running   0          8m
¿Qué significa cada columna?

NAME: El nombre único del pod.

READY: Muestra cuántos contenedores dentro del pod están "listos" del total. 1/1 es lo ideal. Si ves 0/1, algo anda mal.

STATUS: El estado del pod. Los más importantes son:

Running: El pod está funcionando correctamente. ¡Esto es lo que quieres ver!

Pending: El pod fue aceptado por Kubernetes, pero aún no se ejecuta (por ejemplo, está descargando la imagen del contenedor o esperando recursos).

Completed: El pod ejecutó su tarea y terminó exitosamente.

Error / CrashLoopBackOff: El pod ha fallado y Kubernetes está intentando reiniciarlo repetidamente. Este es un signo de problema.

RESTARTS: El número de veces que los contenedores del pod han sido reiniciados. Un número alto indica problemas.

AGE: Cuánto tiempo ha pasado desde que se creó el pod.

2. Ver Pods en TODOS los Namespaces
Si tus aplicaciones están en diferentes espacios de nombres (como en tu script, que usa default, prometheus y grafana), necesitas una vista global.

Bash

kubectl get pods --all-namespaces
O su versión corta:

Bash

kubectl get pods -A
Salida de ejemplo:

NAMESPACE       NAME                                       READY   STATUS      RESTARTS   AGE
default         nginx-deployment-78dcf96497-fghij          1/1     Running     0          10m
grafana         grafana-676d56c547-abcde                   1/1     Running     0          5m
ingress-nginx   ingress-nginx-controller-b958c8a6f-lmnop   1/1     Running     0          15m
kube-system     coredns-787d7b5745-qrstuv                   1/1     Running     0          20m
prometheus      prometheus-server-65c6c888-pqrst           2/2     Running     0          8m
3. Observar los Cambios en Tiempo Real
Si acabas de desplegar algo, es muy útil ver cómo los pods cambian de estado en tiempo real. Para esto, usas la bandera -w (watch).

Bash

kubectl get pods -w
Tu terminal se quedará "enganchada", mostrando los cambios a medida que los pods pasan de Pending a ContainerCreating y finalmente a Running. Para salir, presiona Ctrl + C.

4. Obtener Más Detalles de un Pod Específico
Si un pod no está en estado Running (por ejemplo, está en Error o Pending), el siguiente paso es "describirlo" para obtener un diagnóstico detallado.

Bash

kubectl describe pod <nombre-del-pod> -n <namespace-del-pod>
Ejemplo:

Bash

kubectl describe pod prometheus-server-65c6c888-pqrst -n prometheus
Este comando te dará muchísima información, pero la sección más importante para diagnosticar problemas es la de Events (Eventos) al final. Ahí verás mensajes de error como "Failed to pull image" (no se pudo descargar la imagen), "Insufficient cpu" (CPU insuficiente), o fallos en las pruebas de salud (liveness/readiness probes).

5. Verificar el Estado de los Deployments
A menudo, los pods son gestionados por un recurso de nivel superior llamado Deployment. Verificar el estado del Deployment es una forma más robusta de saber si tu aplicación está desplegada y con la cantidad correcta de réplicas.

Bash

kubectl get deployments -A
Salida de ejemplo:

NAMESPACE    NAME                READY   UP-TO-DATE   AVAILABLE   AGE
default      nginx-deployment    2/2     2            2           12m
grafana      grafana             1/1     1            1           7m
prometheus   prometheus-server   1/1     1            1           10m
La columna clave es READY, que muestra deseadas/actuales. Si ves 2/2 significa que las 2 réplicas que querías están desplegadas y listas.

Resumen Rápido
Para...	Usa el comando...
Ver un resumen rápido de los pods en el namespace actual	kubectl get pods
Ver TODOS los pods en el clúster	kubectl get pods -A
Vigilar los cambios en tiempo real	kubectl get pods -w
Diagnosticar un pod con problemas	kubectl describe pod <nombre-pod> -n <namespace>
Verificar el estado general de las aplicaciones	kubectl get deployments -A