PROJECT=aiops-dev-prometheus-lts
INFLUXDB_STORAGE=50Gi

.PHONY: all init

init: create_project

create_project:
	oc new-project ${PROJECT}

deploy_influx:
	oc new-app -p STORAGE_SIZE="${INFLUXDB_STORAGE}" -l app=influxdb -f ./influxdb.yaml -n ${PROJECT}

delete_influx:
	oc delete all,secret -l app=influxdb -n ${PROJECT}

deploy_prometheus:
	oc new-app -f ./prometheus.yaml -p NAMESPACE=${PROJECT} -l app=prometheus -n ${PROJECT}

delete_prometheus:
#	oc delete all,secret,sa,configmaps,rolebindings -l app=prometheus -n ${PROJECT}
	oc delete all -l app=prometheus -n ${PROJECT}

deploy_grafana:
	oc project ${PROJECT} && ./setup-grafana.sh -n prometheus -p ${PROJECT}

delete_grafana:
	oc delete all,secret,sa,configmaps -l app=grafana -n ${PROJECT}
