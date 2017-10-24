recommendations-repository:
    builder.git_latest:
        - name: git@github.com:elifesciences/recommendations.git
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: {{ salt['elife.rev']() }}
        - branch: {{ salt['elife.branch']() }}
        - target: /srv/recommendations/
        - force_fetch: True
        - force_checkout: True
        - force_reset: True
        - fetch_pull_requests: True
        - require:
            - composer
    file.directory:
        - name: /srv/recommendations
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - builder: recommendations-repository

recommendations-var-folder:
    file.directory:
        - name: /srv/recommendations/var
        - user: {{ pillar.elife.webserver.username }}
        - group: {{ pillar.elife.webserver.username }}
        - dir_mode: 775
        - file_mode: 664
        - recurse:
            - user
            - group
        - require:
            - recommendations-repository

    cmd.run:
        - name: chmod -R g+s /srv/recommendations/var
        - require:
            - file: recommendations-var-folder

recommendations-logs:
    cmd.run:
        - name: |
            mkdir -p logs
            chmod 775 logs
        - cwd: /srv/recommendations/var/
        - user: {{ pillar.elife.webserver.username }}
        - require:
            - recommendations-var-folder

recommendations-configuration:
    file.managed:
        - name: /srv/recommendations/config.php
        - source: salt://recommendations/config/srv-recommendations-config.php
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - template: jinja
        - require:
            - recommendations-repository

recommendations-composer-install:
    cmd.run:
        {% if pillar.elife.env in ['prod', 'demo', 'end2end', 'continuumtest'] %}
        - name: composer --no-interaction install --no-suggest --classmap-authoritative --no-dev
        {% elif pillar.elife.env != 'dev' %}
        - name: composer --no-interaction install --no-suggest --classmap-authoritative
        {% else %}
        - name: composer --no-interaction install --no-suggest
        {% endif %}
        - cwd: /srv/recommendations/
        - user: {{ pillar.elife.deploy_user.username }}
        - env:
            - COMPOSER_DISCARD_CHANGES: 'true'
        - require:
            - recommendations-configuration
            - recommendations-var-folder

recommendations-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/recommendations.conf
        - source: salt://recommendations/config/etc-nginx-sites-enabled-recommendations.conf
        - template: jinja
        - require:
            - nginx-config
            - recommendations-composer-install
        - listen_in:
            - service: nginx-server-service
            - service: php-fpm

syslog-ng-recommendations-logs:
    file.managed:
        - name: /etc/syslog-ng/conf.d/recommendations.conf
        - source: salt://recommendations/config/etc-syslog-ng-conf.d-recommendations.conf
        - template: jinja
        - require:
            - pkg: syslog-ng
            - recommendations-logs
        - listen_in:
            - service: syslog-ng

logrotate-recommendations-logs:
    file.managed:
        - name: /etc/logrotate.d/recommendations
        - source: salt://recommendations/config/etc-logrotate.d-recommendations
        - template: jinja
        - require:
            - recommendations-logs
