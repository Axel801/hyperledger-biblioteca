#!/bin/bash
./../../utils.sh

function createCentroarte() {
    infoln "Enrolling the CA admin"
    mkdir -p organizations/peerOrganizations/centroarte.libro.com/
    
    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/centroarte.libro.com/
    
    set -x
    fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-centroarte --tls.certfiles "${PWD}/organizations/fabric-ca/centroarte/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-centroarte.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-centroarte.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-centroarte.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-centroarte.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/centroarte.libro.com/msp/config.yaml"
    
    infoln "Registering peer0"
    set -x
    fabric-ca-client register --caname ca-centroarte --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/centroarte/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    infoln "Registering peer1"
    set -x
    fabric-ca-client register --caname ca-centroarte --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/centroarte/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    infoln "Registering user"
    set -x
    fabric-ca-client register --caname ca-centroarte --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/centroarte/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    infoln "Registering the org admin"
    set -x
    fabric-ca-client register --caname ca-centroarte --id.name centroarteadmin --id.secret centroarteadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/centroarte/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    infoln "Generating the peer0 msp"
    set -x
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-centroarte -M "${PWD}/organizations/peerOrganizations/centroarte.libro.com/peers/peer0.centroarte.libro.com/msp" --csr.hosts peer0.centroarte.libro.com --tls.certfiles "${PWD}/organizations/fabric-ca/centroarte/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    cp "${PWD}/organizations/peerOrganizations/centroarte.libro.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/centroarte.libro.com/peers/peer0.centroarte.libro.com/msp/config.yaml"
    
    infoln "Generating the peer0-tls certificates"
    set -x
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-centroarte -M "${PWD}/organizations/peerOrganizations/centroarte.libro.com/peers/peer0.centroarte.libro.com/tls" --enrollment.profile tls --csr.hosts peer0.centroarte.libro.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/centroarte/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    cp "${PWD}/organizations/peerOrganizations/centroarte.libro.com/peers/peer0.centroarte.libro.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/centroarte.libro.com/peers/peer0.centroarte.libro.com/tls/ca.crt"
    cp "${PWD}/organizations/peerOrganizations/centroarte.libro.com/peers/peer0.centroarte.libro.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/centroarte.libro.com/peers/peer0.centroarte.libro.com/tls/server.crt"
    cp "${PWD}/organizations/peerOrganizations/centroarte.libro.com/peers/peer0.centroarte.libro.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/centroarte.libro.com/peers/peer0.centroarte.libro.com/tls/server.key"
    
    mkdir -p "${PWD}/organizations/peerOrganizations/centroarte.libro.com/msp/tlscacerts"
    cp "${PWD}/organizations/peerOrganizations/centroarte.libro.com/peers/peer0.centroarte.libro.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/centroarte.libro.com/msp/tlscacerts/ca.crt"
    
    mkdir -p "${PWD}/organizations/peerOrganizations/centroarte.libro.com/tlsca"
    cp "${PWD}/organizations/peerOrganizations/centroarte.libro.com/peers/peer0.centroarte.libro.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/centroarte.libro.com/tlsca/tlsca.centroarte.libro.com-cert.pem"
    
    mkdir -p "${PWD}/organizations/peerOrganizations/centroarte.libro.com/ca"
    cp "${PWD}/organizations/peerOrganizations/centroarte.libro.com/peers/peer0.centroarte.libro.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/centroarte.libro.com/ca/ca.centroarte.libro.com-cert.pem"
    
    
    
    infoln "Generating the user msp"
    set -x
    fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-centroarte -M "${PWD}/organizations/peerOrganizations/centroarte.libro.com/users/User1@centroarte.libro.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/centroarte/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    cp "${PWD}/organizations/peerOrganizations/centroarte.libro.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/centroarte.libro.com/users/User1@centroarte.libro.com/msp/config.yaml"
    
    infoln "Generating the org admin msp"
    set -x
    fabric-ca-client enroll -u https://centroarteadmin:centroarteadminpw@localhost:7054 --caname ca-centroarte -M "${PWD}/organizations/peerOrganizations/centroarte.libro.com/users/Admin@centroarte.libro.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/centroarte/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    cp "${PWD}/organizations/peerOrganizations/centroarte.libro.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/centroarte.libro.com/users/Admin@centroarte.libro.com/msp/config.yaml"
}

function createAnabelsegura() {
    infoln "Enrolling the CA admin"
    mkdir -p organizations/peerOrganizations/anabelsegura.libro.com/
    
    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/
    
    set -x
    fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-anabelsegura --tls.certfiles "${PWD}/organizations/fabric-ca/anabelsegura/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-anabelsegura.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-anabelsegura.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-anabelsegura.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-anabelsegura.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/msp/config.yaml"
    
    infoln "Registering peer0"
    set -x
    fabric-ca-client register --caname ca-anabelsegura --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/anabelsegura/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    infoln "Registering user"
    set -x
    fabric-ca-client register --caname ca-anabelsegura --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/anabelsegura/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    infoln "Registering the org admin"
    set -x
    fabric-ca-client register --caname ca-anabelsegura --id.name anabelseguraadmin --id.secret anabelseguraadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/anabelsegura/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    infoln "Generating the peer0 msp"
    set -x
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-anabelsegura -M "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/peers/peer0.anabelsegura.libro.com/msp" --csr.hosts peer0.anabelsegura.libro.com --tls.certfiles "${PWD}/organizations/fabric-ca/anabelsegura/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    cp "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/peers/peer0.anabelsegura.libro.com/msp/config.yaml"
    
    infoln "Generating the peer0-tls certificates"
    set -x
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-anabelsegura -M "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/peers/peer0.anabelsegura.libro.com/tls" --enrollment.profile tls --csr.hosts peer0.anabelsegura.libro.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/anabelsegura/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    cp "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/peers/peer0.anabelsegura.libro.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/peers/peer0.anabelsegura.libro.com/tls/ca.crt"
    cp "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/peers/peer0.anabelsegura.libro.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/peers/peer0.anabelsegura.libro.com/tls/server.crt"
    cp "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/peers/peer0.anabelsegura.libro.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/peers/peer0.anabelsegura.libro.com/tls/server.key"
    
    mkdir -p "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/msp/tlscacerts"
    cp "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/peers/peer0.anabelsegura.libro.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/msp/tlscacerts/ca.crt"
    
    mkdir -p "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/tlsca"
    cp "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/peers/peer0.anabelsegura.libro.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/tlsca/tlsca.anabelsegura.libro.com-cert.pem"
    
    mkdir -p "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/ca"
    cp "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/peers/peer0.anabelsegura.libro.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/ca/ca.anabelsegura.libro.com-cert.pem"
    
    infoln "Generating the user msp"
    set -x
    fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-anabelsegura -M "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/users/User1@anabelsegura.libro.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/anabelsegura/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    cp "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/users/User1@anabelsegura.libro.com/msp/config.yaml"
    
    infoln "Generating the org admin msp"
    set -x
    fabric-ca-client enroll -u https://anabelseguraadmin:anabelseguraadminpw@localhost:8054 --caname ca-anabelsegura -M "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/users/Admin@anabelsegura.libro.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/anabelsegura/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    cp "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/anabelsegura.libro.com/users/Admin@anabelsegura.libro.com/msp/config.yaml"
}

function createOrderer() {
    infoln "Enrolling the CA admin"
    mkdir -p organizations/ordererOrganizations/libro.com
    
    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/libro.com
    
    set -x
    fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/libro.com/msp/config.yaml"
    
    infoln "Registering orderer"
    set -x
    fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    infoln "Registering the orderer admin"
    set -x
    fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    infoln "Generating the orderer msp"
    set -x
    fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/libro.com/orderers/orderer.libro.com/msp" --csr.hosts orderer.libro.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    cp "${PWD}/organizations/ordererOrganizations/libro.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/libro.com/orderers/orderer.libro.com/msp/config.yaml"
    
    infoln "Generating the orderer-tls certificates"
    set -x
    fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/libro.com/orderers/orderer.libro.com/tls" --enrollment.profile tls --csr.hosts orderer.libro.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    cp "${PWD}/organizations/ordererOrganizations/libro.com/orderers/orderer.libro.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/libro.com/orderers/orderer.libro.com/tls/ca.crt"
    cp "${PWD}/organizations/ordererOrganizations/libro.com/orderers/orderer.libro.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/libro.com/orderers/orderer.libro.com/tls/server.crt"
    cp "${PWD}/organizations/ordererOrganizations/libro.com/orderers/orderer.libro.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/libro.com/orderers/orderer.libro.com/tls/server.key"
    
    mkdir -p "${PWD}/organizations/ordererOrganizations/libro.com/orderers/orderer.libro.com/msp/tlscacerts"
    cp "${PWD}/organizations/ordererOrganizations/libro.com/orderers/orderer.libro.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/libro.com/orderers/orderer.libro.com/msp/tlscacerts/tlsca.libro.com-cert.pem"
    
    mkdir -p "${PWD}/organizations/ordererOrganizations/libro.com/msp/tlscacerts"
    cp "${PWD}/organizations/ordererOrganizations/libro.com/orderers/orderer.libro.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/libro.com/msp/tlscacerts/tlsca.libro.com-cert.pem"
    
    infoln "Generating the admin msp"
    set -x
    fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/libro.com/users/Admin@libro.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
    { set +x; } 2>/dev/null
    
    cp "${PWD}/organizations/ordererOrganizations/libro.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/libro.com/users/Admin@libro.com/msp/config.yaml"
}

