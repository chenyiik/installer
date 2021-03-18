#!/bin/bash

set -e

cd $(dirname $0)

if [ "$1" != "" ]; then
	version=$1
else
	version=0.36.1
fi

rm -rf v${version}.tar.gz frp-$version

wget -c https://github.com/fatedier/frp/archive/v${version}.tar.gz
tar -zxf v${version}.tar.gz

cd frp-$version
make

cd bin
sudo cp -f frps /usr/local/bin/frps-$version
sudo cp -f frpc /usr/local/bin/frpc-$version
sudo ln -fs /usr/local/bin/frps-$version /usr/bin/frps
sudo ln -fs /usr/local/bin/frpc-$version /usr/bin/frpc

cd ../conf
conf_dir=/etc/frp
mkdir -p $conf_dir
sudo cp -n frps.ini $conf_dir
sudo cp -n frpc.ini $conf_dir
sudo cp -n frps_full.ini $conf_dir
sudo cp -n frpc_full.ini $conf_dir

cd systemd
conf_dir=/etc/systemd/system
sudo cp -n frps.service $conf_dir
sudo cp -n frpc.service $conf_dir
sudo cp -n frps@.service $conf_dir
sudo cp -n frpc@.service $conf_dir

rm -rf v${version}.tar.gz frp-$version
