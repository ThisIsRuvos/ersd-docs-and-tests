# ersd-docs-and-tests
> Documentation and tests for ERSD Components

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


### Regarding 🐳Docker🐳
There are several spots where you may want to pull an image from the registry here on Ruvos' GitLab.  To do so, authenticate via `docker login` and a [Personal Access Token](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html):
```bash
docker login -u <USERNAME> -p <GITLAB_PERSONAL_ACCESS_TOKEN> registry.ruvos.com
```


### Keycloak
Check out [ersd-keycloak](https://gitlab.ruvos.com/ersd/ersd-keycloak). It contains documentation regarding running and configuring Keycloak for use with ERSD. I use the `jboss/keycloak` image from [Docker hub](https://hub.docker.com/r/jboss/keycloak/), but the `ersd-keycloak` repository provides a tool for quickly configuring a deployed Keycloak instance with the ERSD requirements.


### SMTP Server
Both the Node application and the HAPI FHIR server need to connect to an SMTP server to send email. We'll do this using [loopingz/aws-smtp-relay](https://hub.docker.com/r/loopingz/aws-smtp-relay), which will proxy SMTP messages to AWS SES. 
```bash
docker run -p 10025:10025 -e AWS_REGION=<AWS_REGION> -e AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID> -e AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY> loopingz/aws-smtp-relay
```
If the container will have AWS access without being explicitly provided credentials, leave those out:
```bash
docker run -p 10025:10025 -e AWS_REGION=<AWS_REGION> loopingz/aws-smtp-relay
```
In any case, route port 10025.


### HAPI FHIR
For this, we've got a custom Docker image. [ersd-hapi-fhir](https://gitlab.ruvos.com/ersd/ersd-hapi-fhir) should have everything you need to know about running and configuring it. 


### ERSD NodeJS Application
[ersd](https://gitlab.ruvos.com/ersd/ersd) is a mirror of Lantana's ERSD repository, which is located [here](https://github.com/lantanagroup/ersd) on GitHub. The docs there provide details regarding how the application can be built, configured, and executed. They do not, however, cover using the Dockerized version.  I'll cover that here.

### The Dockerized ERSD NodeJS Application

```bash
# login if necessary
docker login registry.ruvos.com
# or with credentials inline
docker login -u <USERNAME> -p <GITLAB_PERSONAL_ACCESS_TOKEN> registry.ruvos.com
# run with config passed via environment variable and port 3333 routed
docker run -p 3333:3333 -e NODE_CONFIG=<CONFIG_JSON> -it registry.ruvos.com/ersd/ersd
```
The HTTP server listens on port 3333, so route that accordingly. The `NODE_CONFIG` environment variable allows us to pass the entirety of the app's configuration as JSON. Here's what that might look like:

```bash
docker run -p 3333:3333 -e NODE_CONFIG='{"server":{"authCertificate":"-----BEGIN CERTIFICATE-----\nMIIClzCCAX8CBgFsOjq03zANBgkqhkiG9w0BAQsFADAPMQ0wCwYDVQQDDARlcnNkMB4XDTE5MDcyODIwMTUyMVoXDTI5MDcyODIwMTcwMVowDzENMAsGA1UEAwwEZXJzZDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKykYMfe+vEbthTVNqdqfzIvAGJIxBfRPZ0kxGrxbIw7XQ7cfAF/G+uB6GwUMm0xDQKEv1C5tWJwl+RBKt5cM7UpNAdUEcaXl5cGaibvz9KwgZqBVizRG5URaIzIqBRr7EGq4nVcJhMdNZbZubKQcvVr8HWm4XeYQWMn3Mtuymu4eoIVy+FnIjAvrSwzF5r3s/15NwRCDglz4zHx450IJP9Re22hW3Dods829JOtmnHWERXvUqaBcls6WC9GYiuckOi8A/3o9vpu3ioJVFUFTR/uzymIG6XW1zI4MDUOy0o5w5DNqitWH2rNaS9A73jSxZI/uCUgZ8Y+zd2iwUPL0qMCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAhsgtGaDoYhWG7ICIbatVioQeKUyJUbS8nJ1QWMCiTHfpkhWOgzwQEHhVfJqCLk4/HD2XTjxqzoJEhypCTkSVpMugJe5qkGL6V8vsCpgR+H8r9K+qMqjwdxiW7L5Hgj2S3cTnNQ9zyA/Q3zrrHPi+4ioldb24wgfu4OA40qLSzbz8JGTsDJ1pnPvwmc1l8LJTgf1AquculsjYDJVQzNPmlzalrV7MpKaK2VEHbw89mOCs/AiMaGVI/le7KXkK+wUgz7rGN0wXtgKFSfoBdy19T4oPXPg2h0q3KUtw+Qs4Acuz2Z3cgFlMswq/2eWJSKqKOoKwUG1Po/6U4XZXBUpjIQ==\n-----END CERTIFICATE-----","fhirServerBase":"http://ersd-hapi-fhir:8080/hapi-fhir-jpaserver/fhir","enableSubscriptions":true,"contactInfo":{"checkDurationSeconds":3600}},"email":{"from":"sandboxsupport@aimsplatform.com","host":"aws-smtp-relay","port":10025,"tls":false},"client":{"keycloak":{"url":"http://localhost:8081/auth","realm":"ersd","clientId":"ersd-app"}}}' -it registry.ruvos.com/ersd/ersd
```

Here's the JSON formatted for readability:
```json
{
  "server": {
    "authCertificate": "-----BEGIN CERTIFICATE-----\nMIIClzCCAX8CBgFsOjq03zANBgkqhkiG9w0BAQsFADAPMQ0wCwYDVQQDDARlcnNkMB4XDTE5MDcyODIwMTUyMVoXDTI5MDcyODIwMTcwMVowDzENMAsGA1UEAwwEZXJzZDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKykYMfe+vEbthTVNqdqfzIvAGJIxBfRPZ0kxGrxbIw7XQ7cfAF/G+uB6GwUMm0xDQKEv1C5tWJwl+RBKt5cM7UpNAdUEcaXl5cGaibvz9KwgZqBVizRG5URaIzIqBRr7EGq4nVcJhMdNZbZubKQcvVr8HWm4XeYQWMn3Mtuymu4eoIVy+FnIjAvrSwzF5r3s/15NwRCDglz4zHx450IJP9Re22hW3Dods829JOtmnHWERXvUqaBcls6WC9GYiuckOi8A/3o9vpu3ioJVFUFTR/uzymIG6XW1zI4MDUOy0o5w5DNqitWH2rNaS9A73jSxZI/uCUgZ8Y+zd2iwUPL0qMCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAhsgtGaDoYhWG7ICIbatVioQeKUyJUbS8nJ1QWMCiTHfpkhWOgzwQEHhVfJqCLk4/HD2XTjxqzoJEhypCTkSVpMugJe5qkGL6V8vsCpgR+H8r9K+qMqjwdxiW7L5Hgj2S3cTnNQ9zyA/Q3zrrHPi+4ioldb24wgfu4OA40qLSzbz8JGTsDJ1pnPvwmc1l8LJTgf1AquculsjYDJVQzNPmlzalrV7MpKaK2VEHbw89mOCs/AiMaGVI/le7KXkK+wUgz7rGN0wXtgKFSfoBdy19T4oPXPg2h0q3KUtw+Qs4Acuz2Z3cgFlMswq/2eWJSKqKOoKwUG1Po/6U4XZXBUpjIQ==\n-----END CERTIFICATE-----",
    "fhirServerBase": "http://ersd-hapi-fhir:8080/hapi-fhir-jpaserver/fhir",
    "enableSubscriptions": true,
    "contactInfo": {
      "checkDurationSeconds": 3600
    }
  },
  "email": {
    "from": "sandboxsupport@aimsplatform.com",
    "host": "aws-smtp-relay",
    "port": 10025,
    "tls": false
  },
  "client": {
    "keycloak": {
      "url": "http://keycloak:8080/auth",
      "realm": "ersd",
      "clientId": "ersd-app"
    }
  }
}
```

#### server.authCertificate
Keycloak realm authentication certificate, which can be fetched using the configuration tool in [ersd-keycloak](https://gitlab.ruvos.com/ersd/ersd-keycloak) or by visiting the keycloak admin web app and checking keys under realm settings.

#### server.fhirServerBase
Base URL of the HAPI FHIR server including fhir path. This is wherever you've got [ersd-hapi-fhir](https://gitlab.ruvos.com/ersd/ersd-hapi-fhir) deployed.

#### server.enableSubscriptions
Subscriptions are the main dig in this application. They should be enabled unless you're wanting to run in a debug mode or something of the sort where subscriptions should not be active.

#### server.contactInfo.checkDurationSeconds
Represents how often the ERSD server should check for expired contact information. Every iteration will pull down a full list of the people registered in ERSD (the FHIR server) and check each of their last modified date to determine whether their information has expired. - from [ersd docs](https://gitlab.ruvos.com/ersd/ersd)

#### email.from
The from address for sending emails.

#### email.host
The host of the SMTP server. Presumably this will be pointing to a deployment of [loopingz/aws-smtp-relay](https://hub.docker.com/r/loopingz/aws-smtp-relay)

#### email.port
SMTP port on the email server.

#### email.tls
Flag indicating whether or not to use TLS when connecting to the SMTP server.

#### email.username
Optional username used to authenticate against the SMTP server.

#### email.password
Optional password used to authenticate against the SMTP server.

#### client.keycloak.url
Keycloak URL from the perspective of the client web application. So this would need to be the public-facing URL for Keycloak.

#### client.keycloak.realm
Keycloak realm to use. Probably `ersd` if you use the defaults from the `ersd-keycloak` configuration utility.

#### client.keycloak.clientId
Keycloak clientId to use. Probably `ersd-app` if you use the defaults from the `ersd-keycloak` configuration utility.


There are several other configuration properties available, which are documented over in the [ersd repo](https://gitlab.ruvos.com/ersd/ersd). The ones above, however, are all that I've personally used.


## Deployment/Connectivity Notes
- Keycloak should be exposed publicly
- The ERSD NodeJS app should be exposed publicly
- HAPI FHIR may be kept private but needs to be accessible by the ERSD NodeJS app


## Testing
```bash
# run the dockerized tests
docker run -it registry.ruvos.com/ersd/ersd-docs-and-tests

# or clone this repo
git clone git@gitlab.ruvos.com:ersd/ersd-docs-and-tests.git
cd ersd-docs-and-tests
```

```bash
# 1. Create a test ERSD user in Keycloak
./create-test-user

# 2. Create contact info in ERSD & HAPI FHIR
./create-contact-info

# 3. Send a test email blast to all ERSD users
./test-email-blast

# 4. Upload a test bundle
./test-bundle-upload
```


## Projects
- [ersd](https://gitlab.ruvos.com/ersd/ersd) - ERSD NodeJS application
- [ersd-hapi-fhir](https://gitlab.ruvos.com/ersd/ersd-hapi-fhir) - Dockerized HAPI FHIR Server for ERSD
- [ersd-keycloak](https://gitlab.ruvos.com/ersd/ersd-keycloak) - Keycloak for ERSD
