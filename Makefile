PROJECT=aiops-dev-prometheus-lts
INFLUXDB_STORAGE=1Gi
INFLUXDB_LIMIT_MEMORY=2Gi
INFLUXDB_STORAGE_CLASS_NAME=ceph-dyn-thoth-prod-core
INFLUXDB_ADMIN_PASSWORD=my-secret-password

.PHONY: all init

init: create_project

create_project:
	oc new-project ${PROJECT}

apply_influx:
	oc process \
		-p STORAGE_SIZE="${INFLUXDB_STORAGE}" \
		-p LIMIT_MEMORY=${INFLUXDB_LIMIT_MEMORY} \
		-p ADMIN_PASSWORD=${INFLUXDB_ADMIN_PASSWORD} \
		-p STORAGE_CLASS_NAME=${INFLUXDB_STORAGE_CLASS_NAME} \
		-f ./influxdb.yaml -n ${PROJECT} | oc apply -f -

delete_influx:
	oc process -p STORAGE_SIZE="${INFLUXDB_STORAGE}" -l app=influxdb -f ./influxdb.yaml -n ${PROJECT} | oc delete -f -

deploy_prometheus:
	oc new-app -f ./prometheus.yaml -p NAMESPACE=${PROJECT} -l app=prometheus -n ${PROJECT}

delete_prometheus:
#	oc delete all,secret,sa,configmaps,rolebindings -l app=prometheus -n ${PROJECT}
	oc delete all -l app=prometheus -n ${PROJECT}

deploy_grafana:
	oc project ${PROJECT} && ./setup-grafana.sh -n prometheus -p ${PROJECT}

delete_grafana:
	oc delete all,secret,sa,configmaps -l app=grafana -n ${PROJECT}
