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
	oc delete all,secret,sa,configmaps -l app=prometheus -n ${PROJECT}
	oc delete sa/prometheus-reader sa/deployer sa/builder -n ${PROJECT}

#deploy_grafana:
#	bash ./setup-grafana.sh -n prometheus -p aiops  # add -a for oauth, -e for node exporter
