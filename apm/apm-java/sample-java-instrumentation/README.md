### Demonstration of auto instrumentation for Java app

1. deploy-before-instrumentation.yaml provided for reference as the original deployment manifest. 

2. deploy-after-auto-instrumentation.yaml shows how to auto instrument using splunk-otel-javaagent.jar

Assuming you have Splunk Otel Collector installed in your cluster.
The high level concept of auto instrument steps are here:

a. Using an initContainer to download the splunk-otel-javaagent.jar and store it into a volume. If your environment doesn't have Internet access, alternatively you can download the jar and hosted in in your private repo.
```
      initContainers:
      - name: splunk-otel-init
        image: busybox:1.28
        command: ["/bin/sh","-c"]
        args: ["wget https://github.com/signalfx/splunk-otel-java/releases/latest/download/splunk-otel-javaagent.jar -O /tmp/splunk-otel-javaagent.jar"]
        volumeMounts:
        - mountPath: /tmp
          name: splunk-otel-java
      volumes:
      - emptyDir: {}
        name: splunk-otel-java
```


b. Mount the volume into existing container
```
        volumeMounts:
        - mountPath: /tmp/agent/
          name: splunk-otel-java
```

c. Define additional env variables<br/>
By defining "splunk.metrics.enabled=true", Splunk Otel Javaagent will collect JVM metrics
```
        env:
          - name: SPLUNK_OTEL_AGENT
            valueFrom:
              fieldRef:
                fieldPath: status.hostIP
          - name: OTEL_RESOURCE_ATTRIBUTES
            value: deployment.environment=dev
          - name: OTEL_SERVICE_NAME
            value: java-auto-instrumentation-demo
          - name: OTEL_EXPORTER_OTLP_ENDPOINT
            value: http://$(SPLUNK_OTEL_AGENT):4317
          - name: SPLUNK_METRICS_ENDPOINT
            value: http://$(SPLUNK_OTEL_AGENT):9943
          - name: JAVA_TOOL_OPTIONS
            value: -javaagent:/tmp/agent/splunk-otel-javaagent.jar -Dsplunk.metrics.enabled=true
```
