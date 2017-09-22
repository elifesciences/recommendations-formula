{% set processes = {'recommendations-queue-watch': 3} %}

{% for process, number in processes.iteritems() %}
{{process}}-old-restart-tasks:
    file.absent:
        - name: /etc/init/{{ process }}s.conf
{% endfor %}


{% if salt['grains.get']('oscodename') == 'trusty' %}

recommendations-processes-task:
    file.managed:
        - name: /etc/init/recommendations-processes.conf
        - source: salt://elife/config/etc-init-multiple-processes-parallel.conf
        - template: jinja
        - context:
            processes: {{ processes }}
            timeout: 60

recommendations-processes-start:
    cmd.run:
        - name: start recommendations-processes
        - require:
            - aws-credentials-cli
            - recommendations-composer-install
            - recommendations-create-database            
            - recommendations-processes-task
            {% for process, _number in processes.iteritems() %}
            - file: {{ process }}-init
            {% endfor %}



{% else %}



{% set controller = "recommendations-processes" %}

{{ controller }}-script:
    file.managed:
        - name: /opt/{{ controller }}.sh
        - source: salt://elife/templates/systemd-multiple-processes-parallel.sh
        - template: jinja
        - context:
            processes: {{ processes }}
            timeout: 60

{{ controller }}-service:
    file.managed:
        - name: /lib/systemd/system/{{ controller }}.service
        - source: salt://recommendations/config/lib-systemd-system-{{ controller }}.service

    service.running:
        - name: {{ controller }}
        - require:
            - aws-credentials-cli
            - recommendations-composer-install
            - recommendations-create-database
            - {{ controller }}-script
            - file: {{ controller }}-service
            {% for process, _number in processes.iteritems() %}
            - file: {{ process }}-init
            {% endfor %}


{% endif %}
