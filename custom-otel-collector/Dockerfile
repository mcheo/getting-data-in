FROM golang:1.20 AS build

RUN mkdir /WORK
RUN cd /WORK

RUN GO111MODULE=on go install go.opentelemetry.io/collector/cmd/builder@latest

COPY otelcol-builder.yaml /WORK/otelcol-builder.yaml
RUN CGO_ENABLED=0 builder --config=/WORK/otelcol-builder.yaml

FROM alpine:latest as certs
RUN apk --update add ca-certificates

FROM scratch

ARG USER_UID=10001
USER ${USER_UID}

COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /tmp/dist/otelcol-custom /otelcontribcol

ENTRYPOINT ["/otelcontribcol"]

