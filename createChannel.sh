#!/bin/bash

# imports
# . scripts/envVar.sh
. utils.sh

CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}

: ${CONTAINER_CLI:="docker"}
: ${CONTAINER_CLI_COMPOSE:="${CONTAINER_CLI}-compose"}
infoln "Using ${CONTAINER_CLI} and ${CONTAINER_CLI_COMPOSE}"

if [ ! -d "channel-artifacts" ]; then
    mkdir channel-artifacts
fi

createChannelGenesisBlock() {
    which configtxgen
    if [ "$?" -ne 0 ]; then
        fatalln "configtxgen tool not found."
    fi
    set -x
    configtxgen -profile TwoOrgsApplicationGenesis -outputBlock ./channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
    res=$?
    { set +x; } 2>/dev/null
    verifyResult $res "Failed to generate channel configuration transaction..."
}

createChannel() {
    ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
    ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key
    local rc=1
    local COUNTER=1
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
        sleep $DELAY
        set -x
        osnadmin channel join --channelID $CHANNEL_NAME --config-block ./channel-artifacts/${CHANNEL_NAME}.block -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        let rc=$res
        COUNTER=$(expr $COUNTER + 1)
    done
    osnadmin channel list -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"
    
}


# joinChannel ORG
joinChannel() {
    FABRIC_CFG_PATH=${PWD}/../fabric-samples/config
    ORG=$1
    setVariables $ORG
    local rc=1
    local COUNTER=1
    ## Sometimes Join takes time, hence retry
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
        sleep $DELAY
        set -x
        peer channel join -b $BLOCKFILE >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        let rc=$res
        COUNTER=$(expr $COUNTER + 1)
    done
    cat log.txt
    verifyResult $res "After $MAX_RETRY attempts, peer0.${ORG} has failed to join channel '$CHANNEL_NAME' "
}

setAnchorPeer() {
    ORG=$1
    setVariables $ORG
    ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    
    peer channel fetch config channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c ${CHANNEL_NAME} --tls --cafile "$ORDERER_CA"
    
    cd channel-artifacts
    
    configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
    
    jq '.data.data[0].payload.data.config' config_block.json > config.json
    
    cp config.json config_copy.json
    
    set -x
    # Modify the configuration to append the anchor peer
    jq '.channel_group.groups.Application.groups.'${CORE_PEER_LOCALMSPID}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.'${ORG}'.example.com","port": '${PORT_PEER}'}]},"version": "0"}}' config_copy.json > modified_config.json
    { set +x; } 2>/dev/null
    
    set -x
    configtxlator proto_encode --input config.json --type common.Config --output config.pb
    
    configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
    
    configtxlator compute_update --channel_id ${CHANNEL_NAME} --original config.pb --updated modified_config.pb --output config_update.pb
    
    configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
    
    echo '{"payload":{"header":{"channel_header":{"channel_id":"'${CHANNEL_NAME}'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
    
    configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb
    { set +x; } 2>/dev/null
    cd ..
    
    peer channel update -f channel-artifacts/config_update_in_envelope.pb -c ${CHANNEL_NAME} -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
    
}

FABRIC_CFG_PATH=${PWD}/configtx

## Create channel genesis block
infoln "Generando bloque genesis '${CHANNEL_NAME}.block'"
createChannelGenesisBlock

FABRIC_CFG_PATH=${PWD}/../fabric-samples/config
BLOCKFILE="./channel-artifacts/${CHANNEL_NAME}.block"

## Create channel
infoln "Creando canal: ${CHANNEL_NAME}"
createChannel
successln "Canal creado correctamente"

## Join all the peers to the channel
infoln "Añadiendo centroarte peer al canal..."
joinChannel "centroarte"
successln "centroarte añadido correctamente"

infoln "Añadiendo anabelsegura peer al canal..."
joinChannel "anabelsegura"
successln "anabelsegura añadido correctamente"

## Set the anchor peers for each org in the channel
infoln "Añadiendo anchor peer centroarte..."
setAnchorPeer "centroarte"
successln "Anchor peer centroarte añadido correctamente"

infoln "Añadiendo anchor peer anabelsegura..."
setAnchorPeer "anabelsegura"
successln "Anchor peer anabelsegura añadido correctamente"

successln "Canal '$CHANNEL_NAME' añadido"
