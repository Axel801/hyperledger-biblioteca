. utils.sh


export PATH=${PWD}/../fabric-samples/bin:${PWD}:$PATH

export FABRIC_CFG_PATH=${PWD}/../fabric-samples/config

CHAINCODE_PATH='chaincodes/chaincode-javascript/'

cd ${CHAINCODE_PATH}

npm install

peer lifecycle chaincode package test.tar.gz --path ${CHAINCODE_PATH} --lang node --label test_1.0