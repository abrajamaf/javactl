#!/usr/bin/env bash
cd /BID/bdco-servicios/jar/ || exit
sudo scp -P2290 root@"$HOST":/BID/bdco-servicios/jar/"$jarFile" .
ls /BID/bdco-servicios/systemd/ | cut -d '.' -f1 |grep ${SERV[0]} |xargs -I {} sudo systemctl restart {}
servicesOk=0
servicesDown=0
servSync=$(ls /BID/bdco-servicios/systemd/ | cut -d '.' -f1 |grep ${SERV[0]})
for i in $servSync; do
  status=$(systemctl status "$i" | grep Active | cut -d " " -f5)
  if test "$status" == active; then
    # echo -e  "$(tput setaf 6) ${i} $(tput sgr0) service: OK"|column
    echo -e  "$AZL${i}$NTRO service: OK"|column
    ((servicesOk = servicesOk + 1))
  else
    # echo -e "$(tput setaf 1) ${i} $(tput sgr0) service:$(tput setaf 1) DOWN $(tput sgr0)"
    echo -e "$AZL${i}$NTRO service: DOWN" |column
    ((servicesDown = servicesDown + 1))
  fi
done
echo " "
echo "Services UP: $servicesOk"
echo "Services Down: $servicesDown"
echo "==================================="
