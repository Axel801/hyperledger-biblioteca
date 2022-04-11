. ./utils.sh


export PATH=${PWD}/../fabric-samples/bin:${PWD}:$PATH

export FABRIC_CFG_PATH=${PWD}/../fabric-samples/config

CHAINCODE_PATH='chaincodes/chaincode-javascript/'


function packagingChainCode(){
    cd ${CHAINCODE_PATH}
    
    npm install
    
    cd ../..
    
    peer lifecycle chaincode package test.tar.gz --path ${CHAINCODE_PATH} --lang node --label libros_1.0
    
}

function installChaincode(){
    
    setVariables "centroarte"
    peer lifecycle chaincode install test.tar.gz
    
    setVariables "anabelsegura"
    peer lifecycle chaincode install test.tar.gz
    successln "Añadido correctamente"
}


function approveChaincode(){
    CC_PACKAGE_ID=$1
    println ${CC_PACKAGE_ID}
    ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    
    setVariables "centroarte"
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID ${CHANNEL_NAME} --name libros --signature-policy "OR('CentroArteMSP.member','AnabelSeguraMSP.member')" --version 1.0 --package-id ${CC_PACKAGE_ID} --sequence 1 --tls --cafile ${ORDERER_CA}
    
    setVariables "anabelsegura"
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID ${CHANNEL_NAME} --name libros --signature-policy "OR('CentroArteMSP.member','AnabelSeguraMSP.member')" --version 1.0 --package-id ${CC_PACKAGE_ID} --sequence 1 --tls --cafile ${ORDERER_CA}
    
    setVariables "centroarte"
    peer lifecycle chaincode checkcommitreadiness --channelID ${CHANNEL_NAME} --name libros --signature-policy "OR('CentroArteMSP.member','AnabelSeguraMSP.member')" --version 1.0 --sequence 1 --tls --cafile ${ORDERER_CA} --output json
    
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID ${CHANNEL_NAME} --name libros --signature-policy "OR('CentroArteMSP.member','AnabelSeguraMSP.member')" --version 1.0 --sequence 1 --tls --cafile ${ORDERER_CA} --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/centroarte.example.com/peers/peer0.centroarte.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/anabelsegura.example.com/peers/peer0.anabelsegura.example.com/tls/ca.crt
    
    peer lifecycle chaincode querycommitted --channelID ${CHANNEL_NAME} --name libros --cafile ${ORDERER_CA}
    
    successln "Chaincode añadido y aprobado correctamente"
}

MODE=$1

if [ "$MODE" == "package" ]; then
    println "Empaquetando Chaincode"
    packagingChainCode
    elif [ "$MODE" == "install" ]; then
    infoln "Instalando chaincode"
    installChaincode
    elif [ "$MODE" == "approve" ]; then
    infoln "Instalando chaincode"
    approveChaincode $2
fi
