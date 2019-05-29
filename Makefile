ENV_FILE := .env
include ${ENV_FILE}
export $(shell sed 's/=.*//' ${ENV_FILE})
export PIPENV_DOTENV_LOCATION=${ENV_FILE}

.PHONY: all init

init: create_project

create_project:
	oc new-project ${PROJECT}

apply_influx:
	oc process \
		-p STORAGE_SIZE="${INFLUXDB_STORAGE}" \
		-p LIMIT_MEMORY=${INFLUXDB_LIMIT_MEMORY} \
		-p ADMIN_PASSWORD=${INFLUXDB_ADMIN_PASSWORD} \
		-p STORAGE_CLASS_NAME=${STORAGE_CLASS_NAME} \
		-f ./influxdb.yaml -n ${PROJECT} | oc apply -f -

delete_influx:
	oc process \
		-p STORAGE_SIZE="${INFLUXDB_STORAGE}" \
		-p LIMIT_MEMORY=${INFLUXDB_LIMIT_MEMORY} \
		-p ADMIN_PASSWORD=${INFLUXDB_ADMIN_PASSWORD} \
		-p STORAGE_CLASS_NAME=${INFLUXDB_STORAGE_CLASS_NAME} \
		-f ./influxdb.yaml -n ${PROJECT} | oc delete -f -

apply_prometheus:
	oc process \
		-p NAMESPACE=${PROJECT} \
		-p THANOS_BUCKET=${THANOS_BUCKET} \
		-p THANOS_ACCESS_KEY=${THANOS_ACCESS_KEY} \
		-p THANOS_SECRET_KEY=${THANOS_SECRET_KEY} \
		-p LIMIT_MEMORY_PROMETHEUS=${LIMIT_MEMORY_PROMETHEUS} \
		-p LIMIT_MEMORY_THANOS_SIDECAR=${LIMIT_MEMORY_THANOS_SIDECAR} \
		-p LIMIT_MEMORY_THANOS_STORE=${LIMIT_MEMORY_THANOS_STORE} \
		-p LIMIT_MEMORY_THANOS_QUERY=${LIMIT_MEMORY_THANOS_QUERY} \
		-p PROM_FEDERATE_TARGET=${PROM_FEDERATE_TARGET} \
		-p PROM_FEDERATE_BEARER=${PROM_FEDERATE_BEARER} \
		-f ./prometheus.yaml -n ${PROJECT} | oc apply -f -

delete_prometheus:
	oc process \
		-p NAMESPACE=${PROJECT} \
		-p THANOS_BUCKET=${THANOS_BUCKET} \
		-p THANOS_ACCESS_KEY=${THANOS_ACCESS_KEY} \
		-p THANOS_SECRET_KEY=${THANOS_SECRET_KEY} \
		-p LIMIT_MEMORY_PROMETHEUS=${LIMIT_MEMORY_PROMETHEUS} \
		-p LIMIT_MEMORY_THANOS_SIDECAR=${LIMIT_MEMORY_THANOS_SIDECAR} \
		-p LIMIT_MEMORY_THANOS_STORE=${LIMIT_MEMORY_THANOS_STORE} \
		-p LIMIT_MEMORY_THANOS_QUERY=${LIMIT_MEMORY_THANOS_QUERY} \
		-p PROM_FEDERATE_TARGET=${PROM_FEDERATE_TARGET} \
		-p PROM_FEDERATE_BEARER=${PROM_FEDERATE_BEARER} \
		-f ./prometheus.yaml -n ${PROJECT} | oc delete -f -

apply_thanos_query_store:
	oc process \
		-p NAMESPACE=${PROJECT} \
		-p THANOS_BUCKET=${THANOS_BUCKET} \
		-p THANOS_ACCESS_KEY=${THANOS_ACCESS_KEY} \
		-p THANOS_SECRET_KEY=${THANOS_SECRET_KEY} \
		-p LIMIT_MEMORY_THANOS_STORE=${LIMIT_MEMORY_THANOS_STORE} \
		-p LIMIT_MEMORY_THANOS_QUERY=${LIMIT_MEMORY_THANOS_QUERY} \
		-f ./thanos-store-query.yaml -n ${PROJECT} | oc apply -f -

delete_thanos_query_store:
	oc process \
		-p NAMESPACE=${PROJECT} \
		-p THANOS_BUCKET=${THANOS_BUCKET} \
		-p THANOS_ACCESS_KEY=${THANOS_ACCESS_KEY} \
		-p THANOS_SECRET_KEY=${THANOS_SECRET_KEY} \
		-p LIMIT_MEMORY_THANOS_STORE=${LIMIT_MEMORY_THANOS_STORE} \
		-p LIMIT_MEMORY_THANOS_QUERY=${LIMIT_MEMORY_THANOS_QUERY} \
		-f ./thanos-store-query.yaml -n ${PROJECT} | oc apply -f -

apply_grafana:
	oc process \
		-p NAMESPACE=${PROJECT} \
		-p STORAGE_CLASS_NAME=${STORAGE_CLASS_NAME} \
		-f ./grafana.yaml -n ${PROJECT} | oc apply -f -

delete_grafana:
	oc process \
		-p NAMESPACE=${PROJECT} \
		-p STORAGE_CLASS_NAME=${STORAGE_CLASS_NAME} \
		-f ./grafana.yaml -n ${PROJECT} | oc delete -f -

deploy_influxdb_stats_exporter:
	oc new-app carlpett/influxdb_stats_exporter -l app=influxdb_stats_exporter -e INFLUX_URL=http://influxdb:8086 -e INFLUX_USER=admin -e INFLUX_PASSWORD=${INFLUXDB_ADMIN_PASSWORD}

