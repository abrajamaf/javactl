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
  echo -e " ---------------------------------------------------------------------------- "
  echo -e "| Este Script ayuda al$AMA DESPLIEGUE, INICIO y PARADA$NTRO de los servicios$VDD Java$NTRO    |"
  echo -e "| cluster de$AZL BRADESCO$NTRO                   |"
  echo -e "> ----------------------------------------------------------------------------<"
  echo -e "| Por favor elige la opción que deseas realizar                               |"
  echo -e "> --------------------------------------------------------------------------- <"
  echo -e "| Según sea la elección, necesitará conocer:                                  |"
  echo -e "|$VDE proxy:$NTRO - Un nombre corto del servicio. ej.:$AMA backend1$NTRO                        |"
  echo -e "|        - Puerto local donde se expone el servicio. ej.:$AMA 19418$NTRO               |"
  echo -e "|        - Prefix donde se publicara el servicio. ej.:$AMA /bid2/vi/backend1/rest$NTRO |"
  echo -e "|$VDE html:$NTRO - Un nombre corto del servicio. ej.:$AMA frontend1$NTRO                        |"
  echo -e "|       - PATH absoluto donde se encuentra la página: ej.:$AMA /var/www/frontend1$NTRO |"
  echo -e "|       - Prefix donde se publicara el servicio. ej:$AMA /portal1$NTRO                 |"
  echo -e "> --------------------------------------------------------------------------- <"
  echo -e "| $AMA 1:$VDE proxy $NTRO                                                                  |"
  echo -e "| $AMA 2:$VDE html  $NTRO                                                                  |"
  echo -e "| $AMA 3:$VDE Ver los servicios configurados.  $NTRO                                       |"
  echo -e "| $AMA 4:$VDE Borrar un prefix.  $NTRO                                                     |"
  echo -e "| $AMA q:$VDE Salir. $NTRO                                                                 |"
  echo -e " ----------------------------------------------------------------------------- "
}

function prod() {
  read -p "elija un a oción " OPTION
  grep -v '^ *#' <nodos-prod.txt | while IFS= read -r line; do
  ssh -t "$line" 'bash -s' < servicios.sh "$OPTION"
  done
}
function cert() {
  read -p "elija un a oción" OPTION
  grep -v '^ *#' <nodos-cert.txt | while IFS= read -r line; do
    ssh -t "$line" 'bash -s' <servicios.sh  "$OPTION"
  done
}

function enviroment() {
  if [[ $OPT == "prod" ]]; then
    HOST='172.20.130.110'
    echo "$HOST"
    prod

  elif [[ $OPT == "cert" ]]; then
    HOST='172.20.138.10'
    echo "$HOST"
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
    echo "Gracias por usar mi Script..." && sleep 2
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
