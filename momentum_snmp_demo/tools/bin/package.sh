#!/bin/bash

BIN_DIR=`dirname "$0"`
cd $BIN_DIR/../..

BASE_DIR=`pwd`

echo "Base Dir: " $BASE_DIR

rm -rf $BASE_DIR/output
mkdir $BASE_DIR/output

###################
# Build and Package CLI for OSX
###################
export GOOS="darwin"
echo "Building for $GOOS"

mkdir $BASE_DIR/output/$GOOS
go build -o $BASE_DIR/output/$GOOS/queryMomentum

###################
# Build and Package CLI for Windows
###################
export GOOS="windows"
echo "Building for $GOOS"

mkdir $BASE_DIR/output/$GOOS
go build -o $BASE_DIR/output/$GOOS/queryMomentum.exe

###################
# Build and Package CLI for linux
###################
export GOOS=linux 
export GOARCH=amd64
echo "Building for $GOOS"

mkdir $BASE_DIR/output/$GOOS
go build -o $BASE_DIR/output/$GOOS/queryMomentum


