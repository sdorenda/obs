FROM python:3.12-slim-bookworm AS dependencies

WORKDIR /app

COPY requirements.txt .
RUN pip install --disable-pip-version-check -r requirements.txt

COPY . .

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

# just examples, should be set in pod
#ENV OTEL_SERVICE_NAME testapp
#ENV OTEL_LOG_LEVEL DEBUG
#ENV OTEL_EXPORTER_OTLP_ENDPOINT http://otel-collector.otel-collector:4317

ENTRYPOINT ["opentelemetry-instrument","fastapi", "run","testapp.py"]
