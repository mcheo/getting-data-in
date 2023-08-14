

### Manual Instrumention for Erlang App

1. Update docker-compose.yaml and provide valid SPLUNK_ACCESS_TOKEN and SPLUNK_REALM value

2. Step up the environment
```
docker-compose -f docker-compose.yaml up -d
```

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

5. Sending request to erlang app
```
curl localhost:8080
```

6. To destroy the demo environment
```
docker-compose down
```
