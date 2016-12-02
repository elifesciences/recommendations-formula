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

recommendations-cache:
    file.directory:
        - name: /srv/recommendations/cache
        - user: {{ pillar.elife.webserver.username }}
        - group: {{ pillar.elife.webserver.username }}
        - dir_mode: 775
        - file_mode: 664
        - recurse:
            - user
            - group
        - require:
            - recommendations-repository

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

recommendations-database:
    mysql_database.present:
        - name: {{ pillar.recommendations.db.name }}
        - connection_pass: {{ pillar.elife.db_root.password }}
        - require:
            - mysql-ready

recommendations-database-user:
    mysql_user.present:
        - name: {{ pillar.recommendations.db.user }}
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
        - user: {{ pillar.recommendations.db.user }}
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

## IF WE USE PROPEL
recommendations-propel-config:
    file.managed:
        - name: /srv/recommendations/propel.yml
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - source: salt://recommendations/config/srv-recommendations-propel.yml
        - template: jinja
        - require:
            - recommendations-repository
recommendations-propel:
    cmd.run:
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/recommendations
        - name: composer1.0 run sync
        - require:
            - composer-install
            - file: recommendations-propel-config
            - mysql_grants: recommendations-database-access

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

# For when we have processes.
{% set processes = [] %}
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