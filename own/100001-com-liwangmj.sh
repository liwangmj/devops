#!/usr/bin/env bash

function deploy_common() {
    cd $(dirname $0)/compose

    if [[ "${1}" == "del" ]]; then
        ./del.sh blog-redis cn
        ./del.sh blog cn
        ./del.sh intellij-idea-license-server

    else
        ./reup.sh blog-redis cn
        ./reup.sh blog cn
        ./reup.sh intellij-idea-license-server
    fi

}

function deploy_help() {
    echo "[error] unknown args: $1"
    echo "arg1: 'reup' 'del'"
    exit 0
}

[[ -z "${1-}" ]]
case $1 in
    reup \
    | del) deploy_common "$1" ;;
    *) deploy_help "$0" ;;
esac

exit 0
