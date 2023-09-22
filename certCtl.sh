#!/usr/bin/env bash
#=================================================================================
# Título      : certCtl.sh
# Descripción : permite acciones de control a los servicios Java de bradesco CERT
# Autor       : Abraham Alvarado Fuentes
# Versión     : 1.0.0
# Fecha       : 2023-09-21
# Notas       : Utiliza el archivo
# Uso         : ./certCtl.sh
#=================================================================================

# set -eox pipefail  ## Vebose del scritp
# Colores
# RJO='\e[1;31m'
VDE='\e[1;32m'
AMA='\e[1;33m'
AZL='\e[1;34m'
NTRO='\e[0m'
BLNK='\e[5m'
NGINX='172.20.138.7'
HOST='172.20.138.10'

function menu() {
  echo -e "\n"
  echo -e " 1 =$VDE Despliega$NTRO archivo jar en el servidor \"principal.\""
  echo -e " 2 =$VDE Opciones $NTRO de controles sobre los servicios$AMA Jar$NTRO."
  echo -e " 3 =$AMA Cambia el modo del cluster$NTRO $BLNK Solo Infraesttuctura$NTRO."
  echo -e " q =$VDE Salir $NTRO."
  echo -e "\n"
}

function deployment() {
  # copia y despliega el archivo jar en el servidor "principal"
  echo -e "\n"
  find "$HOME" -name "*.jar"
  echo -e "\n"
  echo " Escriba el nombre del archivo: "
  read -r jarFile
  scp -p -P 2290 "$jarFile" "$HOST":/BID/bdco-servicios/deployment/deppot/
  ssh -t "$HOST" sudo /BID/bdco-servicios/tools/deployment.sh
  exit 0
}

function cert() {
  echo -e "\n"
  echo -e " 2 =$VDE Sincroniza$NTRO los archivos$AMA Jar$NTRO al servidor correspondiente"
  echo -e " 3 =$VDE Detiene$NTRO todos loa servicios Java desplegados en el Cluster"
  echo -e " 4 =$VDE Inicia$NTRO todos loa servicios Java desplegados en el CLuster"
  echo -e " 5 =$VDE Reinicia$NTRO todos loa servicios Java desplegados en el CLuster"
  echo -e " 6 =$VDE Muestra el estado$NTRO de los servicios Java desplegados en el servidor"
  echo -e " 7 =$VDE Es una prueba.$NTRO"
  echo -e " Elija una opción: "
  echo -e "\n"
  read -r OPTION
  grep -v '^ *#' <nodos-cert.txt | while IFS= read -r line; do
    ssh -t "$line" 'bash -s' <certServices.sh "$OPTION"
  done
}

function cluster() {
  # copia y despliega el archivo jar en el servidor "principal"
  echo -e " Ésta opción redirige el tráfico a un$AMA solo Servidor$NTRO,"
  echo -e " o bien, hacia los diversos servidores del cluster"
  echo -e " Solo está permitido para$AZL Infraestructura.$NTRO"
  echo -e " Si esta seguro digite$AMA s$NTRO :"
  read -r ABC
  if [[ "${ABC}" == "s" ]]; then
    echo -e " 1 = Dirige el tráfico a un solo servidor"
    echo -e " 2 = Dirige el tráfico a multinodo."
    echo -e "     Asegurese que los servicios esta sincronizados y corriendo."
    echo -e "     en cada servidor"
    read -r CLUSTER
    if [ "${CLUSTER}" == "1" ]; then
      ssh  $NGINX 'sudo /etc/nginx/conf.d/upstream/nodos/oneNode.sh' ## Cambia Cluster a un nodo
      exit 0
    elif [ "${CLUSTER}" == "2" ]; then
      ssh  $NGINX 'sudo /etc/nginx/conf.d/upstream/nodos/clusterNodes.sh' ## Cambia a multinodo
      exit 0
    else
      # Elcción erronea
      exit 1
    fi
  fi
  exit 1
}

while [[ $OPT != q ]]; do
  menu
  read -r OPT
  case "$OPT" in
  1)
    deployment
    echo " ----------------------------------------------------------------------------- \n "
    read -p "Pulse cualquier tecla para continuar ..." any
    ;;
  2)
    cert
    echo " ----------------------------------------------------------------------------- \n "
    read -p "Pulse cualquier tecla para continuar ..." any
    ;;
  3)
    cluster
    echo " ----------------------------------------------------------------------------- \n "
    read -p "Pulse cualquier tecla para continuar ..." any
    ;;
  q)
    echo "\n Gracias por usar mi Script..."
    exit 0
    ;;
  *)
    echo "Usar: $0 {1|2}"
    echo -e " 1 =$VDE Despliega$NTRO archivo jar en el servidor \"principal.\""
    echo -e " 2 =$VDE Opciones $NTRO de controles sobre los servicios$AMA Jar$NTRO."
    echo -e " 3 =$AMA Cambia el modo del cluster$NTRO"
    echo -e " q =$VDE Salir. $NTRO"
    exit 1
    ;;
  esac
done
