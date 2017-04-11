#!/bin/bash

# exit on any error
set -e

echo "Welcome to Nginx auto scale set configuration."
echo "Number of parameters was: " $#

if [ $# -ne 1 ]; then
    echo usage: $0 {nginx configuration blob URI}
        exit 1
fi

blobUri=$1

setup_package_manager()
{
    echo ">> Install epel-release and related packages."

    # install needed bits in a loop because a lot of installs happen
    # on VM init, so won't be able to grab the dpkg lock immediately
    until yum install -y epel-release vim git htop bmon
    do
        echo ">> Trying again"
        sleep 2
    done
}

setup_nginx()
{
    echo ">> Disable setenforce 0"
    setenforce 0

    echo ">> Install Nginx"

    until yum install -y nginx
    do
        echo "Trying again"
        sleep 2
    done

    echo ">> Setup Nginx"
    wget -O /etc/nginx/nginx.conf ${1}
    mkdir -p /nginxcache

    systemctl start nginx
    systemctl enable nginx
}

setup_package_manager
setup_nginx $blobUri

echo ">> Done!"