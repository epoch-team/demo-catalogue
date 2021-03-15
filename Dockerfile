FROM golang:1.7-alpine
#FROM golang:1.7

COPY . /go/src/github.com/microservices-demo/catalogue
WORKDIR /go/src/github.com/microservices-demo/catalogue

#RUN apk apk update
#RUN apk add curl
#RUN apk add wget
#RUN apk add --no-cache ca-certificates && update-ca-certificates

#RUN curl -O http://www.nic.nec.co.jp/internet/service/web/renewal/ZscalerRootCertificate.crt
#RUN wget http://www.nic.nec.co.jp/internet/service/web/renewal/ZscalerRootCertificate.crt

COPY ZscalerRootCertificate.crt /etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_DIR=/etc/ssl/certs

RUN go get -u github.com/FiloSottile/gvt

RUN export GIT_SSL_NO_VERIFY=1 
RUN gvt restore
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /app ./cmd/cataloguesvc

#FROM alpine:3.4
FROM alpine:3.9

ENV	SERVICE_USER=myuser \
	SERVICE_UID=10001 \
	SERVICE_GROUP=mygroup \
	SERVICE_GID=10001

RUN	addgroup -g ${SERVICE_GID} ${SERVICE_GROUP} 
RUN	adduser -g "${SERVICE_NAME} user" -D -H -G ${SERVICE_GROUP} -s /sbin/nologin -u ${SERVICE_UID} ${SERVICE_USER} 
RUN     apk update
RUN     apk upgrade
#RUN	apk add --update libcap

WORKDIR /
COPY --from=0 /app /app
COPY images/ /images/

RUN	chmod +x /app 
RUN	chown -R ${SERVICE_USER}:${SERVICE_GROUP} /app /images 
#RUN	setcap 'cap_net_bind_service=+ep' /app

USER ${SERVICE_USER}

ARG BUILD_DATE
ARG BUILD_VERSION
ARG COMMIT

LABEL org.label-schema.vendor="Weaveworks" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.version="${BUILD_VERSION}" \
  org.label-schema.name="Socks Shop: Catalogue" \
  org.label-schema.description="REST API for Catalogue service" \
  org.label-schema.url="https://github.com/microservices-demo/catalogue" \
  org.label-schema.vcs-url="github.com:microservices-demo/catalogue.git" \
  org.label-schema.vcs-ref="${COMMIT}" \
  org.label-schema.schema-version="1.0"

CMD ["/app", "-port=8000"]
EXPOSE 8000
#EXPOSE 80
