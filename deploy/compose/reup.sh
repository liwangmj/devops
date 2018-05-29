#!/usr/bin/env bash

function reup_common() {
    cd $(dirname $0)/$1

    if [[ "${2}" == "asia" ]]; then
        docker-compose -f asia.yml pull
        docker-compose -f asia.yml down
        docker-compose -f asia.yml up -d
    else
        docker-compose -f cn.yml pull
        docker-compose -f cn.yml down
        docker-compose -f cn.yml up -d
    fi

    if [[ -n $(docker images | grep none) ]]; then
        docker images | grep none | awk '{print $3 }' | xargs docker rmi
    fi
}

function reup_help() {
    echo "[error] unknown args: $1"
    echo "please input args, example './reup.sh blog cn'"
    echo "arg1: 'blog' 'blog-redis' 'asciiflow' 'intellij-idea-license-server' 'webide' "
    echo "arg2: 'cn' 'asia'"
    echo "arg2 default is 'cn'"
    exit 0
}

[[ -z "${1-}" ]]
case $1 in
    blog \
    | blog-redis \
    | asciiflow \
    | webide \
    | intellij-idea-license-server) ;;
    *) reup_help "$0" ;;
esac

case $2 in
    asia \
    | cn) reup_common "$1" "$2" ;;
    *) reup_common "$1" "cn" ;;
esac

exit 0
