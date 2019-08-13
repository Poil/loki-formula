# Configure Loki Server

```yaml
loki:
  server:
    enable: true
	source: http://mybuildedpackage.com/loki-0.2.0.el7
	source_hash: md5=513a2d3706b59156dc07ca6ec62d444e
    install_dir: /opt
    config:
      auth_enabled: false
      server:
        http_listen_port: 3100
      ingester:
        lifecycler:
          address: 127.0.0.1
          ring:
            kvstore:
              store: inmemory
            replication_factor: 1
          final_sleep: 0s
        chunk_idle_period: 5m
        chunk_retain_period: 30s
      schema_config:
        configs:
          - from: 2018-04-15
            store: boltdb
            object_store: filesystem
            schema: v9
            index:
              prefix: index_
              period: 168h
      storage_config:
        boltdb:
          directory: /var/lib/loki/index
        filesystem:
          directory: /var/lib/loki/chunks
      limits_config:
        enforce_metric_name: false
        reject_old_samples: true
        reject_old_samples_max_age: 168h
      chunk_store_config:
        max_look_back_period: 0
      table_manager:
        chunk_tables_provisioning:
          inactive_read_throughput: 0
          inactive_write_throughput: 0
          provisioned_read_throughput: 0
          provisioned_write_throughput: 0
        index_tables_provisioning:
          inactive_read_throughput: 0
          inactive_write_throughput: 0
          provisioned_read_throughput: 0
          provisioned_write_throughput: 0
        retention_deletes_enabled: false
        retention_period: 0

  promtail:
    install_dir: /opt
	source: http://mybuildedpackage.com/promtail-0.2.0.el7
	source_hash: md5=bd0f67b1ad4f940138723d02afe4e71d
    enable: false
```

```yaml
# Configure Promtail
loki:
  server:
    enable: false
	source: http://mybuildedpackage.com/loki-0.2.0.el7
	source_hash: md5=513a2d3706b59156dc07ca6ec62d444e
  promtail:
    install_dir: /opt
	source: http://mybuildedpackage.com/promtail-0.2.0.el7
	source_hash: md5=bd0f67b1ad4f940138723d02afe4e71d
    enable: true
    config:
      server:
        http_listen_port: 9080
        grpc_listen_port: 0
      positions:
        filename: /opt/promtail/positions.yaml
      clients:
        - url: http://localhost:3100/api/prom/push
      scrape_configs:
        - job_name: journal
          journal:
            path: /run/log/journal
            labels:
              job: systemd-journal
          relabel_configs:
            - source_labels: ['__journal__systemd_unit']
              target_label: 'unit'
```
