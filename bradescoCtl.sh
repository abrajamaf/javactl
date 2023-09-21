#!/usr/bin/env bash
set -eox pipefail
# Colores
# RJO='\e[1;31m'
VDE='\e[1;32m'
AMA='\e[1;33m'
# AZL='\e[1;34m'
NTRO='\e[0m'
# BLNK='\e[5m'

function menu() {
  echo -e " 1 =$VDE Despliega$NTRO archivo jar en el servidor \"principal.\""
  echo -e " 2 =$VDE Opciones $NTRO de controles sobre los servicios$AMA Jar$NTRO."
  echo -e " q =$VDE Salir. $NTRO"
  echo -e "\n"
}

function deployment() {
  # copia y despliega el archivo jar en el servidor "principal"
  echo -e " Ésta opción redirige el tráfico a un$AMA solo Servidor$NTRO "
  echo -e " ¿Está seguro de aplicar el despliegue?"
  echo -e " Si esta seguro digite$AMA s$NTRO :"
  read -r ABC
  if [[ "${ABC}" == "s" ]]; then
    find "$HOME" -name "*.jar"
    echo " Escriba el nombre del archivo: "
    read -r jarFile
    # ssh -t $NGINX 'sudo /etc/nginx/conf.d/upstream/nodos/oneNode.sh'  ## Cambia Cluster a un nodo
    scp -p -P 2290 "$HOME"/"$jarFile" "$HOST":/BID/bdco-servicios/deployment/deppot/
    ssh -t "$HOST" sudo /BID/bdco-servicios/tools/deployment.sh
    exit 0
  fi
  exit 1
}

function cert() {
  echo -e " 2 =$VDE Sincroniza$NTRO los archivos$AMA Jar$NTRO al servidor correspondiente"
  echo -e " 3 =$VDE Detiene$NTRO todos loa servicios Java desplegados en el Cluster"
  echo -e " 4 =$VDE Inicoa$NTRO todos loa servicios Java desplegados en el CLuster"
  echo -e " 5 =$VDE Reinicia$NTRO todos loa servicios Java desplegados en el CLuster"
  echo -e " 6 =$VDE Muestra el estado$NTRO de los servicios Java desplegados en el servidor"
  echo -e " 7 =$VDE Es una prueba.$NTRO"
  echo -e " Elija una opción: "
  echo -e "\n"
  read -r OPTION
  grep -v '^ *#' <nodos-cert.txt | while IFS= read -r line; do
    ssh -t "$line" 'bash -s' <certServices.sh  "$OPTION"
  done
}

while [[ $OPT != q ]]; do
  menu
  read -r OPT
  case "$OPT" in
  1)
    deployment
    echo " ----------------------------------------------------------------------------- "
    read -p "Pulse cualquier tecla para continuar ..." any
    ;;
  2)
    cert
    echo " ----------------------------------------------------------------------------- "
    read -p "Pulse cualquier tecla para continuar ..." any
    ;;
  q)
    echo "Gracias por usar mi Script..."
    clear && exit 0
    ;;
  *)
    echo "Usar: $0 {1|2}"
    echo -e " 1 =$VDE Despliega$NTRO archivo jar en el servidor \"principal.\""
    echo -e " 2 =$VDE Opciones $NTRO de controles sobre los servicios$AMA Jar$NTRO."
    echo -e " q =$VDE Salir. $NTRO"
    exit 1
    ;;
  esac
done
