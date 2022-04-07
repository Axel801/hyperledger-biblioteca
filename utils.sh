#!/bin/bash

C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_BLUE='\033[0;34m'
C_YELLOW='\033[1;33m'

# println echos string
function println() {
    echo -e "$1"
}

# errorln echos i red color
function errorln() {
    println "${C_RED}${1}${C_RESET}"
}

# successln echos in green color
function successln() {
    println "${C_GREEN}${1}${C_RESET}"
}

# infoln echos in blue color
function infoln() {
    println "${C_BLUE}${1}${C_RESET}"
}

# warnln echos in yellow color
function warnln() {
    println "${C_YELLOW}${1}${C_RESET}"
}

# fatalln echos in red color and exits with fail status
function fatalln() {
    errorln "$1"
    exit 1
}

function verifyResult() {
    if [ $1 -ne 0 ]; then
        fatalln "$2"
    fi
}

function setVariables(){
    USING_ORG=$1
    if [ $USING_ORG == "centroarte" ]; then

    export CORE_PEER_TLS_ENABLED=true
    export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/centroarte.example.com/peers/peer0.centroarte.example.com/tls/ca.crt
    export CORE_PEER_LOCALMSPID="CentroArteMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/centroarte.example.com/users/Admin@centroarte.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

  elif [ $USING_ORG == "anabelsegura" ]; then
    export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/anabelsegura.example.com/peers/peer0.anabelsegura.example.com/tls/ca.crt
    export CORE_PEER_LOCALMSPID="AnabelSeguraMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/anabelsegura.example.com/users/Admin@anabelsegura.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
}

export -f errorln
export -f successln
export -f infoln
export -f warnln

export -f verifyResult
export -f setVariables
