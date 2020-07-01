#!/usr/bin/env bash

function deploy_common() {
    cd $(dirname $0)

    if [[ "${1}" == "del" ]]; then
        ./del.sh service_openresty_site cn
        ./del.sh redis cn
        ./del.sh consul cn
        ./del.sh intellij-idea-license-server cn
        ./del.sh webide cn
        ./del.sh asciiflow cn

    else
        ./reup.sh asciiflow cn
        ./reup.sh webide cn
        ./reup.sh intellij-idea-license-server cn
        ./reup.sh consul cn
        ./reup.sh redis cn
        ./reup.sh service_openresty_site cn

    fi

}

deploy_common

exit 0
