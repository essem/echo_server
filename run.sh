#!/bin/sh

export ECHO_SERVER_DB_HOST=genisys
export ECHO_SERVER_DB_PORT=$(kubectl get service echo-db -n echo -o go-template='{{(index .spec.ports 0).nodePort}}')

iex -S mix
