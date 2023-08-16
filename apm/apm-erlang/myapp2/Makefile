PROJECT = myapp
PROJECT_DESCRIPTION = My Demo App
PROJECT_VERSION = 0.1.0

DEPS = cowboy opentelemetry_api opentelemetry opentelemetry_exporter opentelemetry_cowboy tls_certificate_check
dep_cowboy = hex 2.9.0

# OpenTelemetry dependencies
dep_opentelemetry_api = hex 1.0.3
dep_opentelemetry = hex 1.0.5
dep_opentelemetry_exporter = hex 1.0.4
dep_opentelemetry_cowboy = hex 0.2.1
dep_tls_certificate_check = hex 1.19.0


include erlang.mk

run: all
	erl -pa ebin/ -config config/sys.config -eval "myapp_app:start_all()."
