FROM ubuntu

RUN apt-get update && \
  apt-get install -y jq curl

WORKDIR /ersd-tests
COPY ./create-contact-info ./create-contact-info
COPY ./create-test-user ./create-test-user
COPY ./test-bundle-upload ./test-bundle-upload
COPY ./test-bundle-upload-request-body.json ./test-bundle-upload-request-body.json
COPY ./test-email-blast ./test-email-blast

CMD ["/bin/bash"]