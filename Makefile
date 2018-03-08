include .env
export $(shell sed 's/=.*//' .env)

PROJECT=prometheus-lts
INFLUXDB_STORAGE=10Gi

.PHONY: all init delete_sso add_influx_image deploy_influx deploy_storage_adapter deploy_prometheus

create_project:
	oc new-project ${PROJECT}

delete_sso:
	oc delete secret connect-sso
	oc delete secret connect

add_influx_image:
	oc secrets new-dockercfg connect-sso --docker-server=sso.redhat.com --docker-username="${USERNAME}" --docker-password="${PASSWORD}" --docker-email="${EMAIL}" && \
    oc secrets new-dockercfg connect --docker-server="https://registry.connect.redhat.com" --docker-username="${USERNAME}" --docker-password="${PASSWORD}" --docker-email="${EMAIL}" && \
    oc secret link default secret/connect --for=pull && \
    oc import-image influxdb --from=registry.connect.redhat.com/influxdata/influxdb-1x --confirm

deploy_influx:
	oc new-app -p STORAGE_SIZE="${INFLUXDB_STORAGE}" -l app=influxdb -f ./influxdb.yaml

deploy_storage_adapter:
	oc new-app -l app=prometheus-remote-storage-adapter -f ./prometheus-remote-storage-adapter.yaml

deploy_prometheus:
	oc new-app -f ./prometheus.yaml -p NAMESPACE=${PROJECT}

deploy_grafana:
	bash ./setup-grafana.sh -n prometheus -p aiops  # add -a for oauth, -e for node exporter

init: create_project add_influx_image
