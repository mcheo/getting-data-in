
# Splunk Otel Demo - Istio

Sending traces from Istio to Splunk Observability Cloud

Ref: https://docs.splunk.com/Observability/gdi/get-data-in/application/istio/istio.html

### 1. Create k8s cluster 
```
kind create cluster --name splunk-istio --config kind-cluster.yaml
```


### 2. Create a working environment
Create a temp container environment, to keep it clean from your host machine

```
# Create a temp container
docker run -it --rm -v ${HOME}:/root/ -v ${PWD}:/work -p 40080:40080 -w /work --net host alpine sh

# Install utility tools
# a. Install misc package
apk add --no-cache curl vim
apk add --update openssl

# b. Install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
export KUBE_EDITOR="vim"

# c. Download istio
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.17.2 TARGET_ARCH=x86_64 sh -
mv istio-1.17.2/bin/istioctl /usr/local/bin/
chmod +x /usr/local/bin/istioctl
mv istio-1.17.2 /tmp/

# d. Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sh get_helm.sh

```

#### Install Istio
```
# Install Istio
istioctl x precheck
istioctl install --set profile=minimal --set values.pilot.traceSampling=100 -f tracing.yaml

# Install Ingress Controller, use ClusterIP
kubectl create namespace istio-ingress
kubectl apply -f ingress-gateway.yaml
```

#### Deploy Splunk Otel Collector
```
kubectl create ns splunk-otel

helm repo add splunk-otel-collector-chart https://signalfx.github.io/splunk-otel-collector-chart

helm repo update

# Update the correct accessToken and realm information before executing the command below
helm install --set="autodetect.istio=true,autodetect.prometheus=true" --set="splunkObservability.accessToken=<redacted>,clusterName=splunk-istio,splunkObservability.realm=<redacted>,gateway.enabled=false,splunkObservability.profilingEnabled=true,environment=testing" --generate-name splunk-otel-collector-chart/splunk-otel-collector -n splunk-otel

```

#### Deploy demo app
```
kubectl create ns hipstershop
kubectl label namespace/hipstershop istio-injection=enabled
kubectl apply -f hipstershop.yaml -n hipstershop
kubectl apply -f ingress-service.yaml -n hipstershop
```

### 3 Browsing the app
```
# Run this from your host machine assuming you have kubectl in your local machine
kubectl -n istio-ingress port-forward  service/istio-ingressgateway 40080:80

# Use browser extension to add Host header: hipstershop.local.com and start browsing http://localhost:40080
```