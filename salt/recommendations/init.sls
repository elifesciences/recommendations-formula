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
            - php-composer-1.0
            - php-puli-latest
    file.directory:
        - name: /srv/recommendations
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - builder: recommendations-repository

aws-credentials-cli:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/.aws/credentials
        - source: salt://recommendations/config/home-user-.aws-credentials
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - makedirs: True
        - template: jinja
        - require:
            - deploy-user

{% if pillar.elife.env in ['dev', 'ci'] %}
recommendations-queue-create:
    cmd.run:
        - name: aws sqs create-queue --region=us-east-1 --queue-name=recommendations--{{ pillar.elife.env }} --endpoint=http://localhost:4100
        - cwd: /home/{{ pillar.elife.deploy_user.username }}
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - goaws-init
            - aws-credentials-cli
        - require_in:
            - recommendations-console-ready
{% endif %}


recommendations-cache:
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
            - file: recommendations-cache

recommendations-composer-install:
    cmd.run:
        {% if pillar.elife.env in ['prod', 'demo', 'end2end'] %}
        - name: composer1.0 --no-interaction install --classmap-authoritative --no-dev
        {% elif pillar.elife.env in ['ci'] %}
        - name: composer1.0 --no-interaction install --classmap-authoritative
        {% else %}
        - name: composer1.0 --no-interaction install
        {% endif %}
        - cwd: /srv/recommendations/
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - recommendations-cache

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

recommendations-database:
    mysql_database.present:
        - name: {{ pillar.recommendations.db.name }}
        - connection_pass: {{ pillar.elife.db_root.password }}
        - require:
            - mysql-ready

recommendations-database-user:
    mysql_user.present:
        - name: {{ pillar.recommendations.db.username }}
        - password: {{ pillar.recommendations.db.password }}
        - connection_pass: {{ pillar.elife.db_root.password }}
        {% if pillar.elife.env in ['dev'] %}
        - host: '%'
        {% else %}
        - host: localhost
        {% endif %}
        - require:
            - mysql-ready

recommendations-database-access:
    mysql_grants.present:
        - user: {{ pillar.recommendations.db.username }}
        - connection_pass: {{ pillar.elife.db_root.password }}
        - database: {{ pillar.recommendations.db.name }}.*
        - grant: all privileges
        {% if pillar.elife.env in ['dev'] %}
        - host: '%'
        {% else %}
        - host: localhost
        {% endif %}
        - require:
            - recommendations-database
            - recommendations-database-user

recommendations-database-configuration:
    file.managed:
        - name: /srv/recommendations/config/db.ini
        - source: salt://recommendations/config/srv-recommendations-config-db.ini
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - makedirs: True
        - template: jinja
        - require:
            - recommendations-database-user
            - recommendations-repository

recommendations-console-ready:
    cmd.run:
        - name: ./bin/console --env={{ pillar.elife.env }}
        - cwd: /srv/recommendations/
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - recommendations-composer-install

recommendations-create-database:
    cmd.run:
        {% if pillar.elife.env in ['prod', 'end2end'] %}
        - name: ./bin/console generate:database --env={{ pillar.elife.env }}
        {% else %}
        - name: ./bin/console generate:database --drop --env={{ pillar.elife.env }}
        {% endif %}
        - cwd: /srv/recommendations/
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - recommendations-console-ready
            - recommendations-database-configuration
            - aws-credentials-cli

{% if pillar.elife.env in ['dev', 'ci'] %}
recommendations-import-content:
    cmd.run:
        - name: ./bin/ci-import {{ pillar.elife.env }}
        - cwd: /srv/recommendations/
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - recommendations-composer-install
            - api-dummy-nginx-vhost-recommendations
{% endif %}

{% set processes = ['queue-watch'] %}
{% for process in processes %}
recommendations-{{ process }}-service:
    file.managed:
        - name: /etc/init/recommendations-{{ process }}.conf
        - source: salt://recommendations/config/etc-init-recommendations-{{ process }}.conf
        - template: jinja
        - require:
            - aws-credentials-cli
            - recommendations-composer-install
{% endfor %}
