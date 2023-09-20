#!/usr/bin/env bash
# Colores
# RJO='\e[1;31m'
VDE='\e[1;32m'
AMA='\e[1;33m'
# AZL='\e[1;34m'
NTRO='\e[0m'
# BLNK='\e[5m'

function test() {
  echo -e "$AMA${HOSTNAME^^}$NTRO  $(hostname -I)"
  sudo su
  cd /BID/bdco-servicios/jar || exit
  ls -la
  for f in *.jar; do
    # [[ -e "$f" ]] || break
    echo -e "scp -P 2290 -p root@"$HOST":/BID/bdco-servicios/jar/"$f" ."
    ls -la /BID/bdco-servicios/jar/"$f"
  done
  exit 0
}

function deployment() {
  # copia y despliega el archivo jar en el servidor "principal"
  scp -p -P 2290 "$jarFile" "$HOST":/BID/bdco-servicios/deployment/deppot/
  ssh -t "$HOST" /BID/bdco-servicios/tools/deployment.sh
}

function syncJar() {
  # Copia los archivos Jar a los servidores con servicios distribuidos
  echo -e "$AMA${HOSTNAME^^}$NTRO  $(hostname -I)"
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
  cd /BID/bdco-servicios/tools || exit
  sh stop-all-services.sh
  exit 0

}

function startAll() {
  # Inicia todos los servicios Java desplegados en un servidor
  echo -e "$AMA${HOSTNAME^^}$NTRO  $(hostname -I)"
  cd /BID/bdco-servicios/tools || exit
  sh start-all-services.sh
  exit 0
}
function restartAll() {
  # reinica todos los servicios Java desplegado en un servidor
  echo -e "$AMA${HOSTNAME^^}$NTRO  $(hostname -I)"
  cd /BID/bdco-servicios/tools || exit
  sh start-all-services.sh && sh start-all-services.sh
  exit 0
}

function status() {
  echo -e "$AMA${HOSTNAME^^}$NTRO  $(hostname -I)"
  cd /BID/bdco-servicios/tools || exit
  sh status-services.sh
  exit 0
}

if [ "$1" = "--help" ]; then
  $0 any
  exit 0
fi

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
  echo "Usar: $0 {1|2|3|4|5|6}"
  echo -eE "1 =$VDE Despliega$NTRO archivo jar en el servidor \"principal\""
  echo -eE "2 =$VDE Sincroniza$NTRO los archivos$AMA Jar$NTRO al servidor correspondiente"
  echo -eE "3 =$VDE Detiene$NTRO todos loa servicios Java desplegados en el servidor"
  echo -eE "4 =$VDE Inicoa$NTRO todos loa servicios Java desplegados en el servidor"
  echo -eE "5 =$VDE Reinicia$NTRO todos loa servicios Java desplegados en el servidor"
  echo -eE "6 =$VDE Muestra el estado de los servicios Java desplegados en el servidor"
  echo -eE "6 =$VDE Muestra el estado de los servicios Java desplegados en el servidor"
  exit 1
  ;;
esac
