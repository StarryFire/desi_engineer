exporters are services that collect data from various processes running on the same system as they are running on and send it
collector/monitoring services like prometheus, loki, grafana, etc.

Since, these collect data from the same machine as they are running on, it is essential that these should be running on every machine in your infrastructure, hence, i have
collected them under the "exporters" folder

Prometheus is a special case here since it is both a collector and exporter. However, in our case it is serving purely as an exporter which collects metrics from node-exporter, cadvisor, etc.
and then sends it to the collector/monitoring services i.e. grafana

Normally, prometheus architecture includes slave prometheus services that serve as exporters and master prometheus service that serves as the collector/monitoring service.
