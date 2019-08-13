{% from "loki/map.jinja" import loki with context %}

promtail:
  user.present:
    - fullname: promtail daemon
    - gid: systemd-journal
    - system: True

promtail_install_dir:
  file.directory:
    - name: "{{ loki.promtail.install_dir }}/promtail"
    - user: root
    - group: root
    - mode: 0755

promtail_lib_dir:
  file.directory:
    - name: "/var/lib/promtail"
    - user: promtail
    - group: root
    - mode: 0755

promtail_binary:
  file.managed:
    - name: "{{ loki.promtail.install_dir }}/promtail/promtail"
    - user: root
    - group: root
    - mode: '0755'
    - source: "{{ loki.promtail.source }}"
    - source_hash: "{{ loki.promtail.source_hash }}"
    - skip_verify: "{{ loki.promtail.skip_verify }}"

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
          User: promtail
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

promtail:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: promtail_binary
      - file: {{ loki.promtail.install_dir }}/promtail/promtail.yml
      - file: /etc/systemd/system/promtail.service
