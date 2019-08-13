{% from "loki/map.jinja" import loki with context %}
include:
  {%- if loki.server.enable %}
  - loki.server
  {%- endif %}
  {%- if loki.promtail.enable %}
  - loki.promtail
  {%- endif %}

