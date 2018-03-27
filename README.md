# Prometheus Long Term Storage

Create the project with `make init`

## Influx

Deploy influxdb with `make deploy_influx`

## Prometheus

Get the influxdb password for the admin user with

`oc get secrets/admin-password -n aiops-prod-prometheus-lts -o jsonpath --template '{.data.admin_password}' | base64 --decode`

and replace {INFLUX_ADMIN_PASSWORD} in `prometheus.yaml`. 

Deploy prometheus with `make deploy_prometheus`
