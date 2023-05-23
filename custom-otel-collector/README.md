
#### Create custom OpenTelemetry Collector 
Use this guide to generates a custom OpenTelemetry Collector binary:

1. Refer to here for list of open source and vendor supported components.

https://github.com/open-telemetry/opentelemetry-collector-releases/blob/main/distributions/otelcol-contrib/manifest.yaml

2. Update builder file<br/>
Insert the required components into respective sections inside otel-builder.yaml file

3. Build the container
```
docker build -t custom-otel-col . 
```

4. Start the container
```
#example:
docker run -it -d -p 4317:4317 -v ./otelcol.yaml:/etc/otel-collector-config.yaml custom-otel-col --config=/etc/otel-collector-config.yaml
```


Ref: https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder