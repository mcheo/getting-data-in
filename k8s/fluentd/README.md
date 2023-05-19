### Use fluentd in k8s to GDI for Splunk 

Prerequsite: 
- Docker installed
- Kind installed


Steps:

1. We will use [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) to create a demo cluster.
```
kind create cluster --config kind-cluster.yaml --name demo-with-splunk
```

2. Deploy Splunk
```
kubectl create ns splunk
kubectl apply -f splunk.yaml -n splunk
```

3. Access Splunk GUI
You may deploy ingress controller and create ingress resource. Alternatively, you just do a port-forward for quick and easy testing.
```
kubectl port-forward -n splunk deployment/splunk-deployment 8000:8000
```

4. Create HEC Token
a. Settings -> Date Inputs -> HTTP Event Collector -> Add New<br/>
    i. Create any name
    ii. Preferable create a separate new Index for this testing. eg: fluentd
    iii. After completion, copy the "Token Value". We will need to update fluentd configmap
    iv. Open fluentd-configmap.yaml and assign the Token Value to hec_token 

5. Deploy fluentd
```
kubectl create ns fluentd
kubectl apply -f fluentd-rbac.yaml
kubectl apply -f fluentd-configmap.yaml
kubectl apply -f fluentd.yaml
```

7. Deploy a test app
```
kubectl apply -f counter.yaml
```

8. After a few moment, ff everything goes as planned, you may see the logs in Splunk Search app. 
```
index="fluentd"
```

9. Delete kind cluster after testing
```
kind delete cluster --name demo-with-splunk
```