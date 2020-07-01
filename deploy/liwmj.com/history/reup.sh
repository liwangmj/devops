#!/usr/bin/env bash

function reup_common() {
    cd $(dirname $0)/$1

    if [[ "${2}" == "asia" ]]; then
        docker-compose -f $1-asia.yml pull
        docker-compose -f $1-asia.yml down
        docker-compose -f $1-asia.yml up -d
    else
        docker-compose -f $1-cn.yml pull
        docker-compose -f $1-cn.yml down
        docker-compose -f $1-cn.yml up -d
    fi

    if [[ -n $(docker images | grep none) ]]; then
        docker images | grep none | awk '{print $3 }' | xargs docker rmi
    fi
}

function reup_help() {
    echo "[error] unknown args: $1"
    echo "please input args, example './reup.sh service_openresty_site cn'"
    echo "arg1: 'service_openresty_site' 'redis' 'consul' 'webide' 'intellij-idea-license-server' 'asciiflow' "
    echo "arg2: 'cn' 'asia'"
    echo "arg2 default is 'cn'"
    exit 0
}

[[ -z "${1-}" ]]
case $1 in
    service_openresty_site \
    | redis \
    | consul \
    | intellij-idea-license-server \
    | webide \
    | asciiflow) ;;
    *) reup_help "$0" ;;
esac

case $2 in
    asia \
    | cn) reup_common "$1" "$2" ;;
    *) reup_common "$1" "cn" ;;
esac

exit 0
