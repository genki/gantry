#!/bin/sh

docker-machine scp ./docker/run g2:~/gantry
docker-machine scp ./test.conf g2:~/gantry
#docker-machine scp -r ./parsrj.sh g2:~/gantry
#docker-machine scp -r ./unescj.sh g2:~/gantry

CERTS=/etc/docker/certs.d
APP_ROOT=/home/docker-user
ENVS="\
  PATH=\$PATH:\$GOBIN \
  SERVICE_NAME=example-echo \
  ETCD_ENDPOINT=https://etcd:2379 \
  ETCD_CAFILE=$CERTS/ca.crt \
  ETCD_CERTFILE=$CERTS/client.crt \
  ETCD_KEYFILE=$CERTS/client.key.insecure \
  PARSJ=./gantry/parsrj.sh \
  DUMPJ=./gantry/unescj.sh \
  GANTRY_START='nc -l 1234'\
  GANTRY_CHECK='echo check'\
  GANTRY_RELOAD='echo reloaded' \
  GANTRY_TARGET=./gantry/out.conf \
  GANTRY_TEMPLATE=./gantry/test.conf"
docker-machine ssh g2 "sudo -u root $ENVS ./gantry/run"
