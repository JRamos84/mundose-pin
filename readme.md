Laboratorio de DevOps: Guía Rápida
Este proyecto es un laboratorio de DevOps que te permite practicar con herramientas clave como Kubernetes, Nginx, Prometheus y Grafana de manera local y sencilla.

Sigue estos pasos para levantar el entorno. No necesitas ser un experto en programación, solo tienes que copiar y pegar los comandos.

Requisitos Previos
Necesitas instalar tres programas en tu computadora:

Vagrant: Para crear una máquina virtual.

VirtualBox: El programa que Vagrant usa para crear la máquina virtual.

Ansible: Un programa que instala y configura las herramientas dentro de la máquina virtual.

1. Preparar la Máquina Virtual
El archivo principal se llama Vagrantfile. Solo necesitas asegurarte de que está configurado correctamente. En este proyecto, ya está todo listo.

Desde la terminal en la carpeta de este proyecto, ejecuta este comando para crear la máquina virtual y configurar las herramientas básicas.

vagrant up --provision

Nota: Este proceso puede tardar varios minutos en completarse.

2. Desplegar los Servicios
Una vez que el comando anterior termine, la máquina virtual estará lista, pero las aplicaciones aún no se habrán desplegado. Ahora, usaremos un script para desplegar todo en un solo paso.

Entra a la máquina virtual:

vagrant ssh

Ejecuta el script deploy_lab.sh:
Este script se encargará de iniciar Minikube, desplegar Nginx, Prometheus y Grafana, y crear los túneles de red para que puedas acceder a ellos.

/vagrant/deploy_lab.sh

Importante: Este script puede tardar unos minutos en completarse, ya que debe descargar las imágenes de Docker.

3. Acceder a los Servicios
Una vez que el script termine, te mostrará las direcciones web para acceder a cada servicio. Simplemente copia y pega las URLs en tu navegador.

Prometheus: Accede a la interfaz de monitoreo.
http://192.168.56.10:9090

Grafana: Accede a la interfaz de visualización de datos.
http://192.168.56.10:3000

Para iniciar sesión en Grafana, el usuario es admin. La contraseña se genera automáticamente. Para obtenerla, usa este comando dentro de la máquina virtual:
kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

Nginx: Accede a la página web de ejemplo.
http://192.168.56.10:8080

Solución de Problemas
Connection reset by peer: Si ves este error, significa que los túneles de red no están funcionando. Asegúrate de haber ejecutado el script deploy_lab.sh y que la máquina virtual no se haya detenido.

Failed to connect to 192.168.56.10: Este error indica que tu computadora no puede comunicarse con la máquina virtual. El problema podría ser tu firewall. Desactívalo temporalmente o revisa que no esté bloqueando la conexión.