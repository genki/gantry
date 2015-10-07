#!/bin/sh

#docker-machine scp -r ./docker g2:~/gantry
#docker-machine scp ./test.conf g2:~/test.conf

GANTRY_PORT=tcp://104.155.232.12:6479 \
GANTRY_CHECK='echo check' \
GANTRY_RELOAD='echo reloaded' \
GANTRY_TARGET=./tmp/out.conf \
GANTRY_TEMPLATE=./test/test.conf \
GANTRY_SERVER_NAMES="hello world" \
./docker/run nc -l -p 1234
#docker-machine ssh g2 "sudo -u root $ENVS ./gantry/run"
