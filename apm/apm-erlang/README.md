

### Manual Instrumention for Erlang App

Updated: myapp is using rebar3 to build, and myapp2 is using Makefile approach to build

1. Update docker-compose.yaml and provide valid SPLUNK_ACCESS_TOKEN and SPLUNK_REALM value

2. Step up the environment
```
docker-compose -f docker-compose.yaml up -d
```

#### For myapp

3. Enter erlang-app docker shell
```
docker exec -it apm-erlang-erlang-app-1 bash
cd /home/myapp/
```

4. Start erlang app
```
rebar3 compile
rebar3 shell
```

5. Sending request to erlang myapp
```
curl localhost:8080
```


#### For myapp2

6. Enter erlang-app docker shell
```
docker exec -it apm-erlang-erlang-app-1 bash
cd /home/myapp2/
```

7. Start erlang app
```
make
make run
```

8. Sending request to erlang myapp2
```
curl localhost:9090
```

9. To destroy the demo environment
```
docker-compose down
```
