# Prometheus Long Term Storage

Create the project with `make init`

## Influx

Deploy influxdb with `make deploy_influx`

## Prometheus

Get the influxdb password for the admin user with

`oc get secrets/admin-password -n aiops-prod-prometheus-lts -o jsonpath --template '{.data.admin_password}' | base64 --decode`

and replace {INFLUX_ADMIN_PASSWORD} in `prometheus.yaml`. 

Deploy prometheus with `make deploy_prometheus`


## Grafana

We are not using the official grafana image for now, because we need a prometheus datasource configured that can
authenticate via Bearer Token headers, see these upstream issues:  
https://github.com/grafana/grafana/pull/10313#issuecomment-366965400
https://github.com/openshift/openshift-ansible/issues/7735