{% from "loki/map.jinja" import loki with context %}

promtail:
  user.present:
    - fullname: promtail daemon
    - group: root
    - system: True

promtail_install_dir:
  file.directory:
    - name: "{{ loki.promtail.install_dir }}/promtail"
    - user: root
    - group: root
    - mode: 0755

promtail_binary:
  file.managed:
    - name: "{{ loki.promtail.install_dir }}/promtail/promtail"
    - user: root
    - group: root
    - mode: '0755'
    - source: "{{ loki.promtail.source }}"

promtail_service_file:
  file.managed:
    - name: /etc/systemd/system/promtail.service
    - replace: False
    - user: root
    - group: root
    - mode: '0644'

/etc/systemd/system/promtail.service:
  ini.options_present:
    - separator: '='
    - strict: True
    - sections:
        Unit:
          Description: Promtail Server
          After: network-online.target
        Service:
          User: loki
          Restart: on-failure
          ExecStart: {{ loki.promtail.install_dir }}/promtail/promtail -config.file {{ loki.promtail.install_dir }}/promtail/promtail.yml
        Install:
          WantedBy: multi-user.target

{{ loki.promtail.install_dir }}/promtail/promtail.yml:
  file.serialize:
    - dataset:
        {{ loki.promtail.config | yaml() | indent(8) }}
    - formatter: yaml
    - user: root
    - group: root
    - mode: '0644'
