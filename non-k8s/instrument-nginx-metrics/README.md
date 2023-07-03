### Instrument NGINX for metrics

1. Spin up an ubuntu VM

    ```
    multipass launch --name nginx-playground

    multipass shell nginx-playground
    ```

2. Install Splunk Otel Collector in Ubuntu
    https://docs.splunk.com/Observability/gdi/opentelemetry/install-linux.html

    Replace the following variables for your environment:

    SPLUNK_REALM: This is the Realm to send data to. The default is us0. See realms.

    SPLUNK_MEMORY_TOTAL_MIB: This is the total allocated memory in mebibytes (MiB). For example, 512 allocates 512 MiB (500 x 2^20 bytes) of memory.

    SPLUNK_ACCESS_TOKEN: This is the base64-encoded access token for authenticating data ingest requests. See Create and manage organization access tokens using Splunk Observability Cloud.

    Note: Since we won't use fluentd, we can optionally do not install it with "--without-fluentd"

    curl -sSL https://dl.signalfx.com/splunk-otel-collector.sh > /tmp/splunk-otel-collector.sh;
    sudo sh /tmp/splunk-otel-collector.sh --without-fluentd --realm SPLUNK_REALM --memory SPLUNK_MEMORY_TOTAL_MIB -- SPLUNK_ACCESS_TOKEN


    The pipeline is auto configured in here: /etc/otel/collector/agent_config.yaml

    ```
    curl -sSL https://dl.signalfx.com/splunk-otel-collector.sh > /tmp/splunk-otel-collector.sh;
    sudo sh /tmp/splunk-otel-collector.sh --realm SPLUNK_REALM --memory SPLUNK_MEMORY_TOTAL_MIB -- SPLUNK_ACCESS_TOKEN
    ```

    ```
    # To restart
    sudo systemctl restart splunk-otel-collector

    # To check status
    sudo systemctl status splunk-otel-collector
    ```

3. Install NGINX

    We are going to install version 1.20.*
    ```
    sudo apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring

    curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
        | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
        http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
        | sudo tee /etc/apt/sources.list.d/nginx.list

    echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
        | sudo tee /etc/apt/preferences.d/99-nginx

    sudo apt update

    sudo apt install nginx=1.20.2*

    sudo systemctl enable nginx.service
    ```

    If you have already pre-installed, just ensure the required module is installed:
    ```
    nginx -V 2>&1| grep -o http_stub_status_module
    ```


4. Create a nginx status endpoint

    Create a file  /etc/nginx/conf.d/nginx_status.conf

    ```
    server {
      listen 8080;

      location = /nginx_status {
        #stab_status on;
        stub_status;
        access_log off;
        allow 127.0.0.1; # The source IP address of OpenTelemetry Collector.
        deny all;
      }
    }

    ```

    Reload nginx
    ```
    sudo nginx -s reload
    ```

5. Update Otel Collector setting:
    <br/>Ref: https://docs.splunk.com/Observability/gdi/monitors-hosts/nginx.html

    Add a new receiver under receiver section:
    Inside /etc/otel/collector/agent_config.yaml
    ```
    smartagent/nginx:
        type: collectd/nginx
        host: 127.0.0.1
        port: 8080
        name: nginx
    ```

    Update the metrics pipeline:
    ```
    metrics:
          receivers: [smartagent/nginx, hostmetrics, otlp, signalfx, smartagent/signalfx-forwarder]
    ```


    Restart Otel Collector
    ```
    sudo systemctl restart splunk-otel-collector
    ```


6. Generate some testing traffic
    ```
    while true; do curl localhost; sleep 1; done
    ```