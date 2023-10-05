#!/usr/bin/env bash
# set -eox pipefail ## Vebose del scritp
# Colores
RJO='\e[1;31m'
VDE='\e[1;32m'
AMA='\e[1;33m'
AZL='\e[1;34m'
NTRO='\e[0m'
# BLNK='\e[5m'
function enviroment() {
  echo -e " Elija el ambiente que hará los cambios \n"
  echo -e " 1 =$VDE CERTIFICACIÓN.$NTRO"
  echo -e " 2 =$VDE PRODUCCIÓN.$NTRO"
  echo -e " q =$VDE Salir.$NTRO"
  echo -e "\n"
  read -r ENV
  if [ "$ENV" == "1" ]; then
    export ENV_FILE=certServ.txt
  elif [ "$ENV" == "2" ]; then
    export ENV_FILE=prodServ.txt
  else
    echo -e "$RJO ¡Seleccción no disponible.! $NTRO"
    exit 0
  fi
}

function enviroment2() {
  echo -e " Elija el ambiente que hará los cambios \n"
  echo -e " 1 =$VDE CERTIFICACIÓN.$NTRO"
  echo -e " 2 =$VDE PRODUCCIÓN.$NTRO"
  echo -e " q =$VDE Salir.$NTRO"
  echo -e "\n"
  read -r ENV
  if [ "$ENV" == "1" ]; then
    export ENV_FILE=nodos-cert.txt
  elif [ "$ENV" == "2" ]; then
    export ENV_FILE=nodos-prod.txt
  else
    echo -e "$RJO ¡Seleccción no disponible.! $NTRO"
    exit 0
  fi
}

function deployment() {
  # copia y despliega el archivo jar en el servidor "principal"
  echo -e "Archivos disponibles: \n"
  echo "$AZL"
  find "$HOME/" -maxdepth 1 -type f -name "*.jar" | awk -F/ '{print "  " $NF}'
  echo "$NTRO"
  # echo -e "\n"
  echo -e " El script tonará el archivo que se encuentre "
  echo -e " en su$AMA HOME$NTRO = $VDE$HOME$NTRO "
  echo -e " Escriba el nombre del archivo: "
  echo -e "\n"
  read -r jarFile
  # mapfile -d" " -t SERV < <(grep "$jarFile" $ENV_FILE)
  SERV=($(grep "$jarFile" $ENV_FILE))

  scp -p -P 2290 "$HOME/$jarFile" "${SERV[1]}":/BID/bdco-servicios/deployment/deppot/
  ssh -t "${SERV[1]}" sudo /BID/bdco-servicios/tools/deployment.sh
  # sudo rm -f "$HOME/$jarFile"
}

function syncronize() {
  cat $ENV_FILE | cut -d" " -f1
  echo " Escriba el nombre del servicio que desea sincronizar: "
  read -r jarServ
  # mapfile -d" " -t SERV < <(grep "$jarServ" $ENV_FILE)
  SERV=($(grep "$jarFile" $ENV_FILE))
  echo -e "$AMA Copiando archivo $AZL${SERV[3]}$NTRO en ${SERV[2]}"
  ssh -t ${SERV[2]} "sudo scp -p -P2290 root@${SERV[1]}:/BID/bdco-servicios/jar/${SERV[3]} /BID/bdco-servicios/jar/"
  echo -e "$AMA Reiniciando servicios $AZL${SERV[0]}$NTRO en ${SERV[2]} ..."
  ssh -t ${SERV[2]} "sudo ls /BID/bdco-servicios/systemd/ | cut -d '.' -f1 | grep ${SERV[0]} | xargs -i sudo systemctl restart {}"
  echo -e "$AMA Estado de los servicios $AZL${SERV[0]}$NTRO en ${SERV[2]} ..."
  ssh -t ${SERV[2]} "sudo ls /BID/bdco-servicios/systemd/ | cut -d '.' -f1 | grep ${SERV[0]} | xargs -i sudo systemctl ststus {}"
}

function action() {
  echo -e "$AZL"
  cat $ENV_FILE | cut -d" " -f1
  echo -e "$NTRO"
  # echo -e "\n"
  read -p " Elije es servicio: " servicio
  SERV=($(grep "$servicio" $ENV_FILE))
  echo -e "$AMA Deteniendo los servicios $AZL${SERV[0]}$NTRO en ${SERV[2]} ..."
  ssh -t ${SERV[2]} "sudo ls /BID/bdco-servicios/systemd/ | cut -d '.' -f1 | grep ${SERV[0]} | xargs -i sudo systemctl $act {}"
  echo -e "$AMA Estado de los servicios $AZL${SERV[0]}$NTRO en ${SERV[2]} ..."
  ssh -t ${SERV[2]} "sudo ls /BID/bdco-servicios/systemd/ | cut -d '.' -f1 | grep ${SERV[0]} | xargs -i sudo systemctl status {}"
  echo " ----------------------------------------------------------------------------- "
}

function service() {
  echo -e " Elija la acción que desea realizar. \n"
  echo -e " 1 =$VDE Iniciar.$NTRO"
  echo -e " 2 =$VDE Detener.$NTRO"
  echo -e " 3 =$VDE Reiniciar.$NTRO"
  echo -e " 4 =$VDE Status.$NTRO"
  echo -e " q =$VDE Salir.$NTRO"
  echo -e "\n"
  read -r ENV
  if [ "$ENV" == "1" ]; then
    export act=start
    action
  elif [ "$ENV" == "2" ]; then
    export act=stop
    action
  elif [ "$ENV" == "3" ]; then
    export act=restart
    action
  elif [ "$ENV" == "4" ]; then
    echo -e "$AMA Estado de los servicios $AZL${SERV[0]}$NTRO en ${SERV[2]} ..."
    ssh -t ${SERV[2]} "sudo ls /BID/bdco-servicios/systemd/ | cut -d '.' -f1 | grep ${SERV[0]} | xargs -i sudo systemctl status {}"
  else
    echo -e " $RJO ¡Seleccción no disponible.!$NTRO"
  fi
}

function status() {
  grep -v '^ *#' <$ENV_FILE | while IFS= read -r line; do
    # mapfile -d" " -t SERV < <(cat "$line" $ENV_FILE)
    ssh -n -T "$line" 'echo -e $AMA${HOSTNAME^^}$NTRO  $(hostname -I)'
    ssh -n -T "$line" 'sudo /BID/bdco-servicios/tools/status-services.sh'
  done
}

function menu() {
  echo -e "\n"
  echo -e " 1 =$VDE Despliega$NTRO archivo jar en el servidor \"principal\"."
  echo -e " 2 =$VDE Sincroniza$NTRO los servicios en los nodos correspondientes del cluster."
  echo -e " 3 =$VDE Status$NTRO de los servicios en los nodos correspondientes del cluster."
  echo -e " 4 =$VDE Inicia, Detiene, Reinicia y Muestra $NTRO los servicios en los nodos correspondientes del cluster."
  echo -e " q =$VDE Salir$NTRO."
  echo -e "\n"
}

while [[ $OPT != q ]]; do
  menu
  read -r OPT
  case "$OPT" in
  1)
    enviroment
    deployment
    echo " ----------------------------------------------------------------------------- "
    read -p "Pulse cualquier tecla para continuar ..." any
    ;;
  2)
    enviroment
    syncronize
    echo " ----------------------------------------------------------------------------- "
    read -p "Pulse cualquier tecla para continuar ..." any
    ;;
  3)
    enviroment2
    status
    echo " ----------------------------------------------------------------------------- "
    read -p "Pulse cualquier tecla para continuar ..." any
    ;;
  4)
    enviroment
    service
    echo " ----------------------------------------------------------------------------- "
    read -p "Pulse cualquier tecla para continuar ..." any
    ;;
  q)
    echo "Gracias por usar mi Script..."
    exit 0
    ;;
  *)
    echo "Usar: $0 {1|2}"
    exit 1
    ;;
  esac
done
