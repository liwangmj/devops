#!/usr/bin/env bash

function del_common() {
    cd $(dirname $0)/$1

    if [[ "${2}" == "asia" ]]; then
        docker-compose -f asia.yml down
    else
        docker-compose -f cn.yml down
    fi

    if [[ -n $(docker images | grep $1) ]]; then
        docker images | grep $1 | awk '{print $3 }' | xargs docker rmi
    fi
}

function del_help() {
    echo "[error] unknown args: $1"
    echo "please input args, example './reup.sh service_openresty_site cn'"
    echo "arg1: 'service_openresty_site' 'redis' 'asciiflow' 'intellij-idea-license-server' 'webide' "
    echo "arg2: 'cn' 'asia'"
    echo "arg2 default is 'cn'"
    exit 0
}

[[ -z "${1-}" ]]
case $1 in
    service_openresty_site \
    | redis \
    | asciiflow \
    | webide \
    | intellij-idea-license-server) ;;
    *) del_help "$0" ;;
esac

case $2 in
    asia \
    | cn) del_common "$1" "$2" ;;
    *) del_common "$1" "cn" ;;
esac

exit 0
