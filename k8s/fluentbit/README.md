### Use fluentbit in k8s to GDI for Splunk 

Prerequsite: 
- Docker installed
- Kind installed
- Helm installed

Ref: 
- https://docs.fluentbit.io/manual/pipeline/outputs/splunk

Steps:

1. We will use [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) to create a demo cluster.
```
kind create cluster --config kind-cluster.yaml --name demo_with_splunk
```

2. Deploy fluentbit
```
kubectl create ns fluentbit

helm repo add fluent https://fluent.github.io/helm-charts

helm install -n fluentbit fluent-bit fluent/fluent-bit
```

3. Deploy Splunk
```
kubectl create ns splunk
kubectl apply -f splunk.yaml -n splunk
```

4. Access Splunk GUI
You may deploy ingress controller and create ingress resource. Alternatively, you just do a port-forward for quick and easy testing.
```
kubectl port-forward -n splunk deployment/splunk-deployment 8000:8000
```

5. Create HEC Token
a. Settings -> Date Inputs -> HTTP Event Collector -> Add New<br/>
    i. Create any name
    ii. Preferable create a separate new Index for this testing. eg: fluentbit
    iii. After completion, copy the "Token Value". We will need to update fluenbit configmap

6. Update Fluentbi configmap
```
kubectl edit cm -n fluentbit

# Copy the sample from fluent_bit_sample.conf to replace the fluent-bit.conf section inside configmap
```
After updating the configmap, we need to make the fluentbit pod using new configmap. We can delete the pod and let the daeemoset re-deploy the pod.
```
kubectl delete pod `kubectl get pod -n fluentbit -oname| cut -d '/' -f2` -n fluentbit
```

7. Deploy a test app
```
kubectl apply -f counter.yaml
```

8. If everything goes as planned, you may see the logs in Splunk Search app. 
```
index="fluentbit"
```

9. Delete kind cluster after testing
```
kind delete cluster --name demo_with_splunk
```