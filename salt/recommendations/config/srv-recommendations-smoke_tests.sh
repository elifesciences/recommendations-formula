#!/usr/bin/env bash
set -ex

# lsh@2023-07-17: issue #8367, prod-recommendations job is failing smoke tests too quickly.
# [ $(curl --write-out %{http_code} --silent --output /dev/null localhost/ping) == 200 ]

# function copied from (MIT licensed):
# - https://github.com/fernandoacorreia/azure-docker-registry/blob/14c45b7f3daae23ae28259eda0f5e7d4872ea881/tools/scripts/create-registry-server#L16-L31
function retry {
    local max=5 # attempts
    local delay=1 # second
    local n=1
    while true; do
        if "$@"; then
            break
        else
            if [[ $n -lt $max ]]; then
                ((n++))
                echo "Command failed. Attempt $n/$max:"
                sleep $delay;
            else
                echo "The command has failed after $n attempts."
                return 1
            fi
        fi
    done
}

function url_ok() {
    local url=$1
    printf 'requesting %s ... ' "$url"
    local status
    status=$(curl --head --location --connect-timeout 1 --write-out "%{http_code}" --silent --output /dev/null "${url}")
    printf "%s\n" "$status"
    [[ "$status" == 2* ]]
}

timeout=60 # seconds. default 30
docker-wait-healthy recommendations_fpm_1 $timeout
retry url_ok localhost/ping
