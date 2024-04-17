#!/usr/bin/env bash
#=============================================================================
# Titulo      : bradescoCtl.sh
# Descripcion : Realiza tareas de deespliegue actualización y control de
#             : los servicios java de BID-Bradesco
# Autor       : Abraham Alvarado Fuente
# Date        : 2023-09-05
# Notes       :
# Uso         : sh status-services.sh
#=============================================================================
# set -eox pipefail ## Verbose del scritp
cd /opt/bid-scripts/bdco-clt/ || exit
# Colores
RJO='\e[1;31m'
VDE='\e[1;32m'
AMA='\e[1;33m'
AZL='\e[1;34m'
NTRO='\e[0m'
BLNK='\e[5m'
function enviroment() {
  echo -e " Elija el ambiente donde hará los cambios \n"
  echo -e "$AMA 1 $NTRO=$VDE CERTIFICACIÓN.$NTRO"
  echo -e "$AMA 2 $NTRO=$VDE PRODUCCIÓN.$NTRO"
  echo -e "$AMA q $NTRO=$VDE Salir.$NTRO"
  echo -e "\n"
  read -r ENV
  if [ "$ENV" == 1 ]; then
    export ENV_FILE=certServ.txt
    export NGINX="172.20.138.7"
    export TAG="CERTIFICACIÓN"
  elif [ "$ENV" == 2 ]; then
    export ENV_FILE=prodServ.txt
    export NGINX="172.20.130.100"
    export TAG="PRODUCCIÓN"
  else
    echo -e "$RJO ¡Seleccción no disponible.! $NTRO"
  fi
}

function enviroment2() {
  echo -e " Elija el ambiente donde hará los cambios \n"
  echo -e "$AMA 1 $NTRO=$VDE CERTIFICACIÓN.$NTRO"
  echo -e "$AMA 2 $NTRO=$VDE PRODUCCIÓN.$NTRO"
  echo -e "$AMA q $NTRO=$VDE Salir.$NTRO"
  echo -e "\n"
  read -r ENV
  if [ "$ENV" == 1 ]; then
    export ENV_FILE=nodos-cert.txt
    export NGINX="172.20.138.7"
    export TAG="CERTIFICACIÓN"
  elif [ "$ENV" == 2 ]; then
    export ENV_FILE=nodos-prod.txt
    export NGINX="172.20.130.100"
    export TAG="PRODUCCIÓN"
  else
    echo -e "$RJO ¡Seleccción no disponible.! $NTRO"
  fi
}

function deployment() {
  # copia y despliega el archivo jar en el servidor "principal"
  echo -e "Archivos disponibles: "
  echo -e "$AZL"
  find "$HOME/" -maxdepth 1 -type f -name "*.jar" | awk -F/ '{print "  " $NF}'
  echo -e "$NTRO"
  echo -e " ####### Estamos en $VDE $TAG $NTRO  ####### "
  echo -e "\n"
  echo -e " El script tomará el archivo que se encuentre "
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

function rollback() {
  echo -e " ####### Estamos en $VDE $TAG $NTRO  ####### \n"
  SERV=($(grep "opt" $ENV_FILE))
  echo -e " Esta actividad solo actua sobre el servidor $BLNK ${SERV[1]} $NTRO \"proncipal.\" "
  echo -e " Una vez que haya realizado el rollback, debe hacer la sincronización"
  echo -e " del servicio hacia los nodos correspondientes del cluster."
  echo -e "$AMA Los archivos y srpits para rollback tienen un ciclo de vida de 7 días narurales.$NTRO"
  echo -e " Éstos son los scripts de rollback disponibles"
  echo -e "$AZL"
  ssh "${SERV[1]}" 'sudo find /BID/bdco-servicios/deployment/rolback -type f  -mtime -7'
  echo -e "$NTRO"
  # echo -e "\n"
  echo -e " Escriba el nombre del archivo: "
  echo -e "\n"
  read -r rollScript
  echo -e "$RJO ¿Está seguro de hacerlo?$NTRO"
  echo -e " Digite$AMA s$NTRO para ejecurar el rollback o cualquiera para abortar"
  read -r resp
  if [ "$resp" == s ]; then
    ssh -t ${SERV[1]} "sudo $rollScript"
  elif [ "$resp" != s ]; then
    echo -e " Se hará en otro momento."
  fi
}

function loadbalabcer() {
  MODE=$(ssh -T $NGINX sudo cat /etc/nginx/conf.d/upstream/cluster.mode)
  echo -e " Ésta opción redirige el tráfico a un$AMA solo Servidor$NTRO,"
  echo -e " o bien, hacia los diversos servidores del cluster"
  echo -e " Solo está permitido para$AZL Infraestructura.$NTRO"
  echo -e " Si esta seguro digite:$AMA s$NTRO"
  read -r ABC
  if [[ "${ABC}" == s ]]; then
    echo -e " ####### Estamos en $BLNK $VDE $TAG $NTRO  ####### \n"
    echo -e "$AMA Estado actual del balanceador: $BLNK $MODE $NTRO"
    echo -e "$AMA 1$NTRO = Dirige el tráfico a un solo servidor"
    echo -e "$AMA 2$NTRO = Dirige el tráfico a multinodo."
    echo -e "     Asegurese que los servicios estan sincronizados y corriendo."
    echo -e "     en cada servidor"
    read -r CLUSTER
    if [ "${CLUSTER}" == 1 ]; then
      ssh $NGINX 'sudo /etc/nginx/conf.d/upstream/nodos/oneNode.sh' ## Cambia Cluster a un nodo
      echo -e "$AMA Un solo nodo $NTRO"
    elif [ "${CLUSTER}" == 2 ]; then
      ssh $NGINX 'sudo /etc/nginx/conf.d/upstream/nodos/clusterNodes.sh' ## Cambia a multinodo
      echo -e "$VDE Multinodo $NTRO"
    else
      echo -e "$RJO ¡Seleccción no disponible.! $NTRO"
    fi
  fi
}

function syncronize() {
  echo -e " ####### Estamos en $BLNK $VDE $TAG $NTRO  ####### "
  echo -e "$AZL"
  cat $ENV_FILE | cut -d" " -f1
  echo -e "$NTRO"
  echo -e " Escriba el nombre del servicio que desea sincronizar: "
  read -r jarServ
  # mapfile -d" " -t SERV < <(grep "$jarServ" $ENV_FILE)
  SERV=($(grep "$jarServ" $ENV_FILE))
  echo -e "$AMA Copiando archivo $AZL${SERV[3]}$NTRO en ${SERV[2]}"
  ssh -t ${SERV[2]} "sudo scp -p -P2290 root@${SERV[1]}:/BID/bdco-servicios/jar/${SERV[3]} /BID/bdco-servicios/jar/"
  echo -e "$AMA Reiniciando servicios $AZL${SERV[0]}$NTRO en ${SERV[2]} ..."
  ssh -t ${SERV[2]} "sudo ls /BID/bdco-servicios/systemd/ | cut -d '.' -f1 | grep ${SERV[0]} | xargs -i sudo systemctl restart {}"
  echo -e "$AMA Estado de los servicios $AZL${SERV[0]}$NTRO en ${SERV[2]} ..."
  ssh -t ${SERV[2]} "sudo ls /BID/bdco-servicios/systemd/ | cut -d '.' -f1 | grep ${SERV[0]} | xargs -i sudo systemctl status {}"
}

function action() {
  echo -e " ####### Estamos en $VDE $TAG $NTRO  ####### \n"
  echo -e "$AZL"
  cat $ENV_FILE | cut -d" " -f1
  echo -e "$NTRO"
  # echo -e "\n"
  read -p " Elije es servicio: " servicio
  SERV=($(grep "$servicio" $ENV_FILE))
  echo -e "$AMA $accion los servicios $AZL${SERV[0]}$NTRO en ${SERV[2]} ..."
  ssh ${SERV[2]} "sudo ls /BID/bdco-servicios/systemd/ | cut -d '.' -f1 | grep ${SERV[0]} | xargs -i sudo systemctl $act {}"
  echo -e "$AMA Estado de los servicios $AZL${SERV[0]}$NTRO en ${SERV[2]} ..."
  ssh ${SERV[2]} "sudo ls /BID/bdco-servicios/systemd/ | cut -d '.' -f1 | grep ${SERV[0]} | xargs -i sudo systemctl status {}"
  echo " ----------------------------------------------------------------------------- "
}

function service() {
  echo -e " ####### Estamos en $VDE $TAG $NTRO  ####### \n"
  echo -e " Elija la acción que desea realizar. \n"
  echo -e "$AMA 1 $NTRO=$VDE Iniciar.$NTRO"
  echo -e "$AMA 2 $NTRO=$VDE Detener.$NTRO"
  echo -e "$AMA 3 $NTRO=$VDE Reiniciar.$NTRO"
  echo -e "$AMA 4 $NTRO=$VDE Status.$NTRO"
  echo -e "$AMA q $NTRO=$VDE Salir.$NTRO"
  echo -e "\n"
  read -r ENV
  if [ "$ENV" == "1" ]; then
    export act=start
    export accion=Iniciando
    action
  elif [ "$ENV" == "2" ]; then
    export act=stop
    export accion=Deteniendo
    action
  elif [ "$ENV" == "3" ]; then
    export act=restart
    export accion=Reiniciando
    action
  elif [ "$ENV" == "4" ]; then
    echo -e "$AZL"
    cat $ENV_FILE | cut -d" " -f1
    echo -e "$NTRO"
    # echo -e "\n"
    read -p " Elije es servicio: " servicio
    SERV=($(grep "$servicio" $ENV_FILE))
    echo -e "$AMA Estado de los servicios $AZL${SERV[0]}$NTRO en ${SERV[2]} ..."
    ssh ${SERV[2]} "sudo ls /BID/bdco-servicios/systemd/ | cut -d '.' -f1 | grep ${SERV[0]} | xargs -i sudo systemctl status {}"
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
  echo -e "$AMA 1$NTRO =$VDE Despliega$NTRO archivo jar en el servidor \"principal\"."
  echo -e "$AMA 2$NTRO =$VDE Sincroniza$NTRO los servicios en los nodos correspondientes del cluster."
  echo -e "$AMA 3$NTRO =$VDE Status$NTRO de los servicios en los nodos correspondientes del cluster."
  echo -e "$AMA 4$NTRO =$VDE Inicia, Detiene, Reinicia y Muestra $NTRO los servicios en los nodos correspondientes del cluster."
  echo -e "$AMA 5$NTRO =$VDE Rollback$NTRO de un servicio."
  echo -e "$AMA 6$NTRO =$VDE Load Balancer$NTRO de un servicio."
  echo -e "$AMA q$NTRO =$VDE Salir$NTRO."
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
  5)
    enviroment
    rollback
    echo " ----------------------------------------------------------------------------- "
    read -p "Pulse cualquier tecla para continuar ..." any
    ;;
  6)
    enviroment2
    loadbalabcer
    echo " ----------------------------------------------------------------------------- "
    read -p "Pulse cualquier tecla para continuar ..." any
    ;;
  q)
    echo "Gracias por usar mi Script..."
    exit 0
    ;;
  *)
    echo "Usar: $0"
    exit 1
    ;;
  esac
done
