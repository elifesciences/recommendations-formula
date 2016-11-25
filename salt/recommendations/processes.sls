{% set processes = {} %}
{% for process, number in processes.iteritems() %}
recommendations-{{ process }}-task:
    file.managed:
        - name: /etc/init/recommendations-{{ process }}.conf
        - source: salt://elife/config/etc-init-multiple-processes.conf
        - template: jinja
        - context:
            process: recommendations-{{ process }}
            number: {{ number }}
        - require:
            - file: recommendations-{{ process }}-service

recommendations-{{ process }}-start:
    cmd.run:
        - name: start recommendations-{{ process }}
        - require:
            - recommendations-{{ process }}-task
{% endfor %}
