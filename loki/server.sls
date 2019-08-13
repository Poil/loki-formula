{% from "loki/map.jinja" import loki with context %}

loki_user:
  user.present:
    - name: loki
    - fullname: loki daemon
    - system: True

loki_install_dir:
  file.directory:
    - name: "{{ loki.server.install_dir }}/loki"
    - user: loki
    - group: loki

loki_binary:
  file.managed:
    - name: "{{ loki.server.install_dir }}/loki/loki"
    - user: root
    - group: root
    - mode: '0755'
    - source: "{{ loki.server.source }}"
    - source_hash: "{{ loki.server.source_hash }}"
    - skip_verify: "{{ loki.server.skip_verify }}"

loki_service_file:
  file.managed:
    - name: /etc/systemd/system/loki.service
    - replace: False
    - user: root
    - group: root
    - mode: '0644'

/etc/systemd/system/loki.service:
  ini.options_present:
    - separator: '='
    - strict: True
    - sections:
        Unit:
          Description: Loki Server
          After: network-online.target
        Service:
          User: loki
          Restart: on-failure
          ExecStart: {{ loki.server.install_dir }}/loki/loki -config.file {{ loki.server.install_dir }}/loki/loki.yml
        Install:
          WantedBy: multi-user.target

{{ loki.server.install_dir }}/loki/loki.yml:
  file.serialize:
    - dataset:
        {{ loki.server.config | yaml() | indent(8) }}
    - formatter: yaml
    - user: root
    - group: root
    - mode: '0644'

loki_service:
  service.running:
    - name: loki
    - enable: True
    - reload: False
    - watch:
      - file: loki_binary
      - file: {{ loki.server.install_dir }}/loki/loki.yml
      - file: /etc/systemd/system/loki.service
