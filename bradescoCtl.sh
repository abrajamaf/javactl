#!/usr/bin/env bash
set -eox pipefail
# Colores
# RJO='\e[1;31m'
VDE='\e[1;32m'
AMA='\e[1;33m'
AZL='\e[1;34m'
NTRO='\e[0m'
# BLNK='\e[5m'

function menu() {
  echo -e " 1 =$VDE Despliega$NTRO archivo jar en el servidor \"principal\""
  echo -e " 2 =$VDE Sincroniza$NTRO los archivos$AMA Jar$NTRO al servidor correspondiente"
  echo -e " 3 =$VDE Detiene$NTRO todos loa servicios Java desplegados en el Cluster"
  echo -e " 4 =$VDE Inicoa$NTRO todos loa servicios Java desplegados en el CLuster"
  echo -e " 5 =$VDE Reinicia$NTRO todos loa servicios Java desplegados en el CLuster"
  echo -e " 6 =$VDE Muestra el estado$NTRO de los servicios Java desplegados en el servidor"
  echo -e " 7 =$VDE Es una prueba.$NTRO"
}

function prod() {
menu
read -p " Elija una opción: " OPTION
  grep -v '^ *#' <nodos-prod.txt | while IFS= read -r line; do
    ssh "$line" 'bash -s' <prodServices.sh $OPTION
  done
}
function cert() {
  menu
  read -p " Elija una opción: " OPTION
  grep -v '^ *#' <nodos-cert.txt | while IFS= read -r line; do
    ssh -t "$line" 'bash -s' <certServices.sh $OPTION
  done
}

function enviroment() {
  if [[ $OPT == "prod" ]]; then
    HOST='172.20.130.110'
    prod

  elif [[ $OPT == "cert" ]]; then
    HOST='172.20.138.10'
    cert
  else
    echo "El server no existe"
  fi
}

# if [ "$1" = "--help" ]; then
#   $0 any
#   exit 0
# fi
while [[ $OPT != q ]]; do
  echo Hola
  read -r OPT
  case "$OPT" in
  prod)
    enviroment
    echo -e " ----------------------------------------------------------------------------- "
    read -p "Pulse cualquier tecla para continuar ..." any
    ;;
  cert)
    enviroment
    echo -e " ----------------------------------------------------------------------------- "
    read -p "Pulse cualquier tecla para continuar ..." any
    ;;
  q)
    echo "Gracias por usar mi Script..."
    clear && exit 0
    ;;
  *)
    echo "Usar: $0 {1|2|3|4|5|6}"
    echo -e "1 =$VDE Despliega$NTRO archivo jar en el servidor \"principal\""
    echo -e "2 =$VDE Sincroniza$NTRO los archivos$AMA Jar$NTRO al servidor correspondiente"
    echo -e "3 =$VDE Detiene$NTRO todos loa servicios Java desplegados en el servidor"
    echo -e "4 =$VDE Inicoa$NTRO todos loa servicios Java desplegados en el servidor"
    echo -e "5 =$VDE Reinicia$NTRO todos loa servicios Java desplegados en el servidor"
    echo -e "6 =$VDE Muestra el estado de los servicios Java desplegados en el servidor"
    echo -e "6 =$VDE Muestra el estado de los servicios Java desplegados en el servidor"
    exit 1
    ;;
  esac
done
