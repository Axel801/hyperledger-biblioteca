. ./utils.sh

export PATH=${PWD}/../fabric-samples/bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false


function networkUp() {
    
    # Validamos si existe
    if [ ! -d "organizations/peerOrganizations" ]; then
        createOrgs
    fi
    
    docker-compose -f compose/compose-test-net.yaml -f compose/docker/docker-compose-test-net.yaml -f compose/compose-couch.yaml up -d 2>&1
}

# Crea las organizaciones usando la CA
function createOrgs() {
    # Eliminamos si ya existen
    if [ -d "organizations/peerOrganizations" ]; then
        rm -Rf organizations/peerOrganizations && rm -Rf organizations/ordererOrganizations
    fi
    
    
    infoln "Generando certificados usando Fabric CA"
    docker-compose -f compose/compose-ca.yaml up -d 2>&1
    # TODO
    . organizations/fabric-ca/registerEnroll.sh
    
    while :
    do
        if [ ! -f "organizations/fabric-ca/centroarte/tls-cert.pem" ]; then
            sleep 1
        else
            break
        fi
    done
    
    infoln "Creando identificacion CentroArte"
    
    createCentroArte
    
    infoln "Creando identificacion AnabelSegura"
    
    createAnabelSegura
    
    infoln "Creando identificacion Orderer Org"
    
    createOrderer
    
}

function networkDown(){
    ids=$(docker ps -a -q)
    docker stop $ids
    docker rm $ids
    docker volume prune -f
    docker network prune -f
    sudo rm -rf organizations/fabric-ca/anabelsegura/
    sudo rm -rf organizations/fabric-ca/centroarte/
    sudo rm -rf organizations/fabric-ca/ordererOrg/
    sudo rm -rf organizations/peerOrganizations
    sudo rm -rf organizations/ordererOrganizations
    sudo rm -rf channel-artifacts/
    mkdir channel-artifacts
}

function createChannel(){
    . createChannel.sh $CHANNEL_NAME
}

function invokeChaincode(){
    . installChaincode.sh $1 $2
}

function appMessage(){
    echo " ____    _   _       _   _           _                               _   _                                 _                  _                       "
    echo "| __ )  (_) | |__   | | (_)   ___   | |_    ___    ___    __ _      | | | |  _   _   _ __     ___   _ __  | |       ___    __| |   __ _    ___   _ __ "
    echo "|  _ \  | | | '_ \  | | | |  / _ \  | __|  / _ \  / __|  / _\` |     | |_| | | | | | | '_ \   / _ \ | '__| | |      / _ \  / _\` |  / _\` |  / _ \ | '__|"
    echo "| |_) | | | | |_) | | | | | | (_) | | |_  |  __/ | (__  | (_| |     |  _  | | |_| | | |_) | |  __/ | |    | |___  |  __/ | (_| | | (_| | |  __/ | |   "
    echo "|____/  |_| |_.__/  |_| |_|  \___/   \__|  \___|  \___|  \__,_|     |_| |_|  \__, | | .__/   \___| |_|    |_____|  \___|  \__,_|  \__, |  \___| |_|   "
    echo "                                                                             |___/  |_|                                           |___/               "
}
appMessage
# Obtenemos el primer parámetro
MODE=$1
CHANNEL_NAME="libroschannel"

if [ "$MODE" == "up" ]; then
    println "Proceso de despliegue comenzando..."
    networkUp
    elif [ "$MODE" == "down" ]; then
    infoln "Stopping network"
    networkDown
    elif [ "$MODE" == "restart" ]; then
    infoln "Restarting network"
    networkDown
    networkUp
    elif [ "$MODE" == "createChannel" ]; then
    infoln "Creando canal '${CHANNEL_NAME}'."
    createChannel
    elif [ "$MODE" == "packageChaincode" ]; then
    infoln "Empaquetando chaincode"
    invokeChaincode package
    elif [ "$MODE" == "installChaincode" ]; then
    infoln "Instalando chaincode"
    invokeChaincode install
    elif [ "$MODE" == "approveChaincode" ]; then
    infoln "Aprovando chaincode"
    invokeChaincode approve $2
fi



