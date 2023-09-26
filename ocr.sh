#!/usr/bin/env bash

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