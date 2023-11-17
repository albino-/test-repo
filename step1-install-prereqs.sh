#!/bin/bash

NODE_MAJOR=20  #major version of node to install

if [[ "${EUID}" -ne 0 ]]; then
	echo "This script should only be run by the root user.  Exiting."
	exit 1
fi

if [[ ! -f "/etc/apt/apt.conf.d/99localpref" ]]; then
	echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d/99localpref
	echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/99localpref
fi

apt update
apt --yes install python3 ca-certificates curl

install -d /etc/apt/keyrings
curl -s 'https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key' > /etc/apt/keyrings/nodesource.asc

export DPKG_ARCH="$(dpkg --print-architecture)"

echo "deb [signed-by=/etc/apt/keyrings/nodesource.asc arch=${DPKG_ARCH}] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list


apt update
apt --yes install nodejs

echo "== debug this buddy"
dpkg --list | grep yarn

echo "== yarn version before trying to change version"
which yarn
yarn --version

echo "== yarn change version"
corepack enable
yarn set version '3.x.x'

echo "== yarn version after trying to change version"
which yarn
yarn --version
