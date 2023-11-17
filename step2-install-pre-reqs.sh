#!/bin/bash

set -x

if [[ "${EUID}" -ne 0 ]]; then
	echo "This script should only be run by the root user.  Exiting."
	exit 1
fi

if [[ ! -f "/etc/apt/apt.conf.d/99localpref" ]]; then
	echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d/99localpref
	echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/99localpref
fi

#install yarn
corepack enable
