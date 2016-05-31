#!/bin/bash

set -o errexit
set -o pipefail

export GO15VENDOREXPERIMENT=1
export GOOS=linux

# Build Rocker
cd ${GOPATH}/src/github.com/github.com/grammarly/rocker
go build -ldflags "-X main.Version=$ROCKER_VERSION" -o ${GOPATH}/bin/

# Build Rocker-compose
cd ${GOPATH}/src/github.com/github.com/grammarly/rocker-compose
go build -ldflags "-X main.Version=$ROCKER_COMPOSE_VERSION" -o ${GOPATH}/bin/

cp -f ${GOPATH}/bin/* /output/
