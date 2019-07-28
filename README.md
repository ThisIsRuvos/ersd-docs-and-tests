# ersd-docs
> Documentation for all ERSD Components

## Setup

### Database(s)
HAPI FHIR and Keycloak will both need some manner of persistent storage. Assuming this is MySQL, you might do the following:
```bash
mysql -u root -p
> create database hapi_dstu3;
> create database keycloak;
> grant all privileges on hapi_dstu3.* to 'hapi_user'@'%' identified by 'hapi-pass';
> grant all privileges on keycloak.* to 'keycloak'@'%' identified by 'kc-pass';
```
Generically,
```bash
mysql -u root -p
> create database <HAPI_FHIR_DB_NAME>;
> create database <KEYCLOAK_DB_NAME>;
> grant all privileges on <HAPI_FHIR_DB_NAME>.* to <HAPI_FHIR_DATASOURCE_USERNAME>@'%' identified by <HAPI_FHIR_DATASOURCE_PASSWORD>;
> grant all privileges on <KEYCLOAK_DB_NAME>.* to <KEYCLOAK_DB_USER>@'%' identified by <KEYCLOAK_DB_PASS>;
```

Note that the database names, usernames, and passwords used here are expected to match the configuration you provide to HAPI FHIR and Keycloak.


### Keycloak
Check out [ersd-keycloak](https://gitlab.ruvos.com/ersd/ersd-keycloak). It contains documentation regarding running and configuring Keycloak for use with ERSD. I use the `jboss/keycloak` image from [Docker hub](https://hub.docker.com/r/jboss/keycloak/), but the `ersd-keycloak` repository provides a tool for quickly configuring a deployed Keycloak instance with the ERSD requirements.


## Projects
- [ersd](https://gitlab.ruvos.com/ersd/ersd) - ERSD NodeJS application
- [ersd-hapi-fhir](https://gitlab.ruvos.com/ersd/ersd-hapi-fhir) - Dockerized HAPI FHIR Server for ERSD
- [ersd-keycloak](https://gitlab.ruvos.com/ersd/ersd-keycloak) - Keycloak for ERSD
