#!/usr/bin/env bash
set -eox pipefail

# Colores
# RJO='\e[1;31m'
VDE='\e[1;32m'
AMA='\e[1;33m'
# AZL='\e[1;34m'
NTRO='\e[0m'
# BLNK='\e[5m'
HOST='172.20.138.10'
NGINX='172.20.138.7'
function test() {
  echo -e "$AMA${HOSTNAME^^}$NTRO  $(hostname -I)"
  sudo su
  cd /BID/bdco-servicios/jar || exit
  ls -la
  for f in *.jar; do
    # [[ -e "$f" ]] || break
    pwd
    echo -e "scp -P 2290 -p root@"$HOST":/BID/bdco-servicios/jar/"$f" ."
    ls -la /BID/bdco-servicios/jar/"$f"
  done
  exit 0
}

function deployment() {
  # copia y despliega el archivo jar en el servidor "principal"
  echo -e " Ésta opción redirige el tráfico a un$AMA solo Servidor$NTRO "
  echo -e " ¿Está seguro de aplicar el despliegue?"
  echo -e " Si esta seguro digite$AMA s$NTRO :"
  read -r ABC
  if [[ "${ABC}" == "s" ]]; then
    # ls -1 *jar
    read -p "Escriba el nombre del archivo: " jarFile
    ssh -t $NGINX 'sudo /etc/nginx/conf.d/upstream/nodos/oneNode.sh'
    scp -p -P 2290 "$jarFile" "$HOST":/BID/bdco-servicios/deployment/deppot/
    ssh -t "$HOST" sudo /BID/bdco-servicios/tools/deployment.sh
  fi
  exit
}

function syncJar() {
  # Copia los archivos Jar a los servidores con servicios distribuidos
  echo -e "$AMA${HOSTNAME^^}$NTRO  $(hostname -I)"
  sudo su
  cd /BID/bdco-servicios/jar || exit
  for f in *.jar; do
    [[ -e "$f" ]] || break
    scp -P 2290 -p root@"$HOST":/BID/bdco-servicios/jar/"$f" .
    ls -la /BID/bdco-servicios/jar/"$f"
  done
  exit 0
}

function stopAll() {
  # Detiene todos loa servicios Java desplegados en el servidor
  echo -e "$AMA${HOSTNAME^^}$NTRO  $(hostname -I)"
  sudo su
  cd /BID/bdco-servicios/tools || exit
  sh stop-all-services.sh
  exit 0

}

function startAll() {
  # Inicia todos los servicios Java desplegados en un servidor
  echo -e "$AMA${HOSTNAME^^}$NTRO  $(hostname -I)"
  sudo su
  cd /BID/bdco-servicios/tools || exit
  sh start-all-services.sh
  exit 0
}
function restartAll() {
  # reinica todos los servicios Java desplegado en un servidor
  echo -e "$AMA${HOSTNAME^^}$NTRO  $(hostname -I)"
  sudo su
  cd /BID/bdco-servicios/tools || exit
  sh start-all-services.sh && sh start-all-services.sh
  exit 0
}

function status() {
  echo -e "$AMA${HOSTNAME^^}$NTRO  $(hostname -I)"
  sudo su
  cd /BID/bdco-servicios/tools || exit
  sh status-services.sh
  exit 0
}

function menu() {
  echo -e " 1 =$VDE Despliega$NTRO archivo jar en el servidor \"principal\""
  echo -e " 2 =$VDE Sincroniza$NTRO los archivos$AMA Jar$NTRO al servidor correspondiente"
  echo -e " 3 =$VDE Detiene$NTRO todos loa servicios Java desplegados en el Cluster"
  echo -e " 4 =$VDE Inicoa$NTRO todos loa servicios Java desplegados en el CLuster"
  echo -e " 5 =$VDE Reinicia$NTRO todos loa servicios Java desplegados en el CLuster"
  echo -e " 6 =$VDE Muestra el estado$NTRO de los servicios Java desplegados en el servidor"
  echo -e " 7 =$VDE Es una prueba.$NTRO"
}

while [[ $1 != q ]]; do
  # menu
  # read -r ACTION
  case "${1}" in
  1)
    deployment
    ;;
  2)
    syncJar
    ;;
  3)
    stopAll
    ;;
  4)
    startAll
    ;;
  5)
    restartAll
    ;;
  6)
    status
    ;;
  7)
    test
    ;;
  *)
    echo "Usar: $0 {1|2|3|4|5|6|7}"
    echo -e " 1 =$VDE Despliega$NTRO archivo jar en el servidor \"principal\""
    echo -e " 2 =$VDE Sincroniza$NTRO los archivos$AMA Jar$NTRO al servidor correspondiente"
    echo -e " 3 =$VDE Detiene$NTRO todos loa servicios Java desplegados en el Cluster"
    echo -e " 4 =$VDE Inicoa$NTRO todos loa servicios Java desplegados en el CLuster"
    echo -e " 5 =$VDE Reinicia$NTRO todos loa servicios Java desplegados en el CLuster"
    echo -e " 6 =$VDE Muestra el estado$NTRO de los servicios Java desplegados en el servidor"
    echo -e " 7 =$VDE Es una prueba.$NTRO"
    exit 1
    ;;
  esac
done
