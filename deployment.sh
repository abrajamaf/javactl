#!/usr/bin/env bash
set -eox pipefail ## Vebose del scritp

function deployment() {
  # copia y despliega el archivo jar en el servidor "principal"
  echo -e "\n"
  find "$HOME/" -maxdepth 1 -type f -name "*.jar" | awk -F/ '{print $NF}'
  echo -e "\n"
  echo " Escriba el nombre del archivo: "
  read -r jarFile
  SERV=($(grep "$jarFile" certServ.txt))

  scp -p -P 2290 "$HOME/$jarFile" "${SERV[1]}":/BID/bdco-servicios/deployment/deppot/
  ssh -t "${SERV[1]}" sudo /BID/bdco-servicios/tools/deployment.sh
  sudo rm -f "$HOME/$jarFile"
  exit 0
}
function syncronize() {
  ssh -t "${SERV[1]}" 'bash -s' <synProd.sh
}
function menu() {
  echo -e "\n"
  echo -e " 1 =$VDE Despliega$NTRO archivo jar en el servidor \"principal.\""
  echo -e " 2 =$VDE Sincroniza $NTRO los servicios en los nodos correspondientes del cluster."
  echo -e " q =$VDE Salir $NTRO."
  echo -e "\n"
}


# echo "${alfresco[2]}"
# deployment

# echo "${all_services[@]}"
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
    syncronize
    echo " ----------------------------------------------------------------------------- "
    read -p "Pulse cualquier tecla para continuar ..." any
    ;;
  q)
    echo "Gracias por usar mi Script..."
    clear && exit 0
    ;;
  *)
    echo "Usar: $0 {1|2}"
    exit 1
    ;;
  esac
done
