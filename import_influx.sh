#!/usr/bin/env bash

set -x
source ./.env

oc delete secret connect-sso
oc delete secret connect

oc secrets new-dockercfg connect-sso --docker-server=sso.redhat.com --docker-username="${USERNAME}" --docker-password="${PASSWORD}" --docker-email="${EMAIL}"
oc secrets new-dockercfg connect --docker-server="https://registry.connect.redhat.com" --docker-username="${USERNAME}" --docker-password="${PASSWORD}" --docker-email="${EMAIL}"
oc secret link default secret/connect --for=pull

oc import-image influxdb-1x --from=registry.connect.redhat.com/influxdata/influxdb-1x --confirm

