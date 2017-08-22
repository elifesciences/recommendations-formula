api-dummy-recommendations-repository:
    cmd.run:
        - name: echo "recommendations-repository is ready for api-dummy-repository"
        - require:
            - recommendations-repository
        - require_in:
            - cmd: api-dummy-repository

api-dummy-nginx-vhost-recommendations:
    file.managed:
        - name: /etc/nginx/sites-enabled/api-dummy-recommendations.conf
        - source: salt://recommendations/config/etc-nginx-sites-enabled-api-dummy-recommendations.conf
        - require:
            - api-dummy-composer-install
            - recommendations-nginx-vhost
        - listen_in:
            - service: nginx-server-service
            - service: php-fpm
