#FROM golang:1.7-alpine3.5
#FROM golang:1.7
FROM golang
#FROM ubuntu:18.04

# gitが通ったら元に戻す
#COPY . /go/src/github.com/microservices-demo/catalogue
#WORKDIR /go/src/github.com/microservices-demo/catalogue

#RUN   ls  -l  /usr/bin/apt*

RUN   "/usr/bin/apt-get"    "update"
RUN   "/usr/bin/apt-get"    "install"   "-y"    "ca-certificates"
COPY  ZscalerRootCertificate.crt  /usr/local/share/ca-certificates
RUN   update-ca-certificates

#RUN   "/usr/bin/apt-get"  "install" "-y" "software-properties-common"
#RUN "/usr/bin/add-apt-repository" "ppa:git-core/ppa"
#RUN "/usr/bin/apt-get"    "update"
#ENV DEBIAN_FRONTEND=noninteractive
#RUN   "/usr/bin/apt-get"    "install"   "-y"    "git"   "golang-go"

#RUN "/usr/bin/apt-get" "upgrade" "-y"
#RUN git config --global --add http.sslVersion tlsv1
RUN git config --global http.postBuffer 524288000
RUN git config --global core.compression -1
#RUN git config --global http.postBuffer 64M
#RUN git config --system http.postBuffer 64M
#ENV GIT_TRACE_PACKET=1
#ENV GIT_TRACE=1
#ENV GIT_CURL_VERBOSE=1
#RUN export GIT_TRACE_PACKET=1
#RUN export GIT_TRACE=1
#RUN export GIT_CURL_VERBOSE=1

RUN git clone https://go.googlesource.com/protobuf

RUN go get github.com/golang/protobuf/proto

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
