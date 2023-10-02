#!/usr/bin/env bash
set -eox pipefail  ## Vebose del scritp
# Colores
RJO='\e[1;31m'
VDE='\e[1;32m'
AMA='\e[1;33m'
AZL='\e[1;34m'
NTRO='\e[0m'
BLNK='\e[5m'
NGINX='172.20.138.7'
HOST='172.20.138.10'
# Servicios
db_router=('db-router' '172.20.130.112' 'digital-enrollment-db-router-0.0.1-SNAPSHOT.jar')
alfresco=('alfresco' '172.20.130.114' 'digital-enrollment-service-alfresco-0.0.1-SNAPSHOT.jar')
biometric_facial_v2=('biometric-facial-v2' '172.20.130.113' 'digital-enrollment-service-biometric-facial-v2-0.0.1-SNAPSHOT.jar')
bradesco_crons=('bradesco-crons' '172.20.130.113' 'digital-enrollment-service-bradesco-crons-0.0.1-SNAPSHOT.jar')
bradesco_v2=('bradesco-v2' '172.20.130.115' 'digital-enrollment-service-bradesco-v2-0.0.1-SNAPSHOT.jar')
configuration_v2=('configuration-v2' '172.20.130.114' 'digital-enrollment-service-configuration-v2-0.0.1-SNAPSHOT.jar')
contracts_v2=('contracts-v2' '172.20.130.120' 'digital-enrollment-service-contracts-v2-0.0.1-SNAPSHOT.jar')
cryptography_v2=('cryptography-v2' '172.20.130.112' 'digital-enrollment-service-cryptography-v2-0.0.1-SNAPSHOT.jar')
documents_v2=('documents-v2' '172.20.130.117' 'digital-enrollment-service-documents-v2-0.0.1-SNAPSHOT.jar')
external_v2=('external-v2' '172.20.130.112' 'digital-enrollment-service-external-v2-0.0.1-SNAPSHOT.jar')
ine_v2=('ine-v2' '172.20.130.115' 'digital-enrollment-service-ine-v2-0.0.1-SNAPSHOT.jar')
login_v2=('login-v2' '172.20.130.113' 'digital-enrollment-service-login-v2-0.0.1-SNAPSHOT.jar')
notification_v2=('notification-v2' '172.20.130.119' 'digital-enrollment-service-notification-v2-0.0.1-SNAPSHOT.jar')
ocr_v2=('ocr-v2' '172.20.130.116' 'digital-enrollment-service-ocr-v2-0.0.1-SNAPSHOT.jar')
operations_v2=('operations-v2' '172.20.130.115' 'digital-enrollment-service-operations-v2-0.0.1-SNAPSHOT.jar')
person_v2=('person-v2' '172.20.130.114' 'digital-enrollment-service-person-v2-0.0.1-SNAPSHOT.jar')
scoring_v2=('shcoring-v2' '172.20.130.118' 'digital-enrollment-service-scoring-v2-0.0.1-SNAPSHOT.jar')
tkn_v2=('tkn-v2' '172.20.130.112' 'digital-enrollment-service-tkn-v2-0.0.1-SNAPSHOT.jar')
users_v2=('users-v2' '172.20.130.113' 'digital-enrollment-service-users-v2-0.0.1-SNAPSHOT.jar')
opt=('opt' '172.20.130.113' 'opt-0.0.1-SNAPSHOT.jar')
all_services=('db_router' 'alfresco' 'biometric_facial_v2' 'bradesco_crons' 'bradesco_v2' 'configuration_v2' 'contracts_v2' 'cryptography_v2' 'documents_v2' 'external_v2' 'ine_v2' 'login_v2' 'notification_v2' 'ocr_v2' 'operations_v2' 'person_v2' 'scoring_v2' 'tkn_v2' 'users_v2' 'opt')

function deployment() {
  # copia y despliega el archivo jar en el servidor "principal"
  echo -e "\n"
  find "$HOME/" -maxdepth 1 -type f -name "*.jar"|awk -F/ '{print $NF}'
  echo -e "\n"
  echo " Escriba el nombre del archivo: "
  read -r jarFile
  SERV=( $(grep "$jarFile" prodServ.txt) )

  echo -e "scp -p -P 2290 "$jarFile" "${SERV[1]}":/BID/bdco-servicios/deployment/deppot/"
  echo -e "ssh -t "${servi[1]}" sudo /BID/bdco-servicios/tools/deployment.sh"
  exit 0
}


# echo "${alfresco[2]}"
deployment

# echo "${all_services[@]}"