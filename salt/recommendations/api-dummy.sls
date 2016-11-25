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
