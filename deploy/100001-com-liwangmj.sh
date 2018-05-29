#!/usr/bin/env bash

function deploy_common() {
    cd $(dirname $0)/compose

    if [[ "${1}" == "del" ]]; then
        ./del.sh asciiflow cn
        ./del.sh intellij-idea-license-server cn
        ./del.sh webide cn
        ./del.sh blog-redis cn
        ./del.sh blog cn

    else
        ./reup.sh asciiflow cn
        ./reup.sh intellij-idea-license-server cn
        ./reup.sh webide cn
        ./reup.sh blog-redis cn
        ./reup.sh blog cn
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
