recommendations-folder:
    file.directory:
        - name: /srv/recommendations
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group

recommendations-folder-old-git-repository:
    file.absent:
        - name: /srv/recommendations/.git
        - require:
            - recommendations-folder

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
            - recommendations-folder

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
        - runas: {{ pillar.elife.webserver.username }}
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
            - recommendations-folder

recommendations-docker-compose-env:
    file.managed:
        - name: /srv/recommendations/.env
        - source: salt://recommendations/config/srv-recommendations-.env
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - template: jinja
        - require:
            - recommendations-folder

recommendations-docker-compose-containers-env:
    file.managed:
        - name: /srv/recommendations/containers.env
        - source: salt://recommendations/config/srv-recommendations-containers.env
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - template: jinja
        - require:
            - recommendations-folder

# deprecated, remove when no longer necessary
stop-existing-php-fpm:
    cmd.run:
        - name: stop php7.0-fpm || true
        # if not stopped, may conflict with port 9000 forwarded from the host to the container
        - require_in:
            - cmd: recommendations-docker-compose

recommendations-docker-compose:
    file.managed:
        - name: /srv/recommendations/docker-compose.yml
        - source: salt://recommendations/config/srv-recommendations-docker-compose.yml
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - template: jinja
        - require:
            - recommendations-docker-compose-env
            - recommendations-docker-compose-containers-env

    cmd.run:
        - name: |
            rm -f docker-compose.override.yml
            docker-compose up -d --force-recreate
        - cwd: /srv/recommendations
        - runas: {{ pillar.elife.deploy_user.username }}
        - require:
            - file: recommendations-docker-compose

{% if pillar.elife.webserver.app == "caddy" %}

recommendations-folder-web:
    file.managed:
        - name: /srv/recommendations/web/app.php
        - contents: '# placeholder. Nginx and Caddy requires this file to pass requests to a php-fpm container'
        - makedirs: True
        - require:
            - recommendations-folder

recommendations-vhost:
    file.managed:
        - name: /etc/caddy/sites.d/recommendations
        - source: salt://recommendations/config/etc-caddy-sites.d-recommendations
        - template: jinja
        - require:
            - caddy-config
            - recommendations-docker-compose
            - recommendations-folder-web
        - listen_in:
            - service: caddy-server-service

{% else %}
recommendations-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/recommendations.conf
        - source: salt://recommendations/config/etc-nginx-sites-enabled-recommendations.conf
        - template: jinja
        - require:
            - nginx-config
            - recommendations-docker-compose
        - listen_in:
            - service: nginx-server-service

{% endif %}

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

recommendations-smoke-tests:
    file.managed:
        - source: salt://recommendations/config/srv-recommendations-smoke_tests.sh
        - name: /srv/recommendations/smoke_tests.sh
        - mode: 755
        - require:
            - recommendations-folder
