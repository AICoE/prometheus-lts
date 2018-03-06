# Prometheus Long Term Storage

## Red Hat Container catalog

Due to an issue with the container catalog, we need to connect our sso credentials
```
cp .env.example .env
```
Then add your Red Hat Access ( https://access.redhat.com/ ) credentials to `.env` 

## deploy

```
# creates project and imports influx images
make init
make deploy_influx
make deploy_prometheus
make deploy_storage_adapter
```