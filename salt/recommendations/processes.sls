{% set processes = {'recommendations-queue-watch': 1} %}

{% for process, number in processes.iteritems() %}
{{process}}-old-restart-tasks:
    file.absent:
        - name: /etc/init/{{ process }}s.conf
{% endfor %}

recommendations-processes-task:
    file.managed:
        - name: /etc/init/recommendations-processes.conf
        - source: salt://elife/config/etc-init-multiple-processes-parallel.conf
        - template: jinja
        - context:
            processes: {{ processes }}
            timeout: 60
        - require:
            {% for process, _number in processes.iteritems() %}
            - file: {{ process }}-service
            {% endfor %}

recommendations-processes-start:
    cmd.run:
        - name: start recommendations-bot-processes
        - require:
            - recommendations-processes-task
