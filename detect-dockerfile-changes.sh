#!/bin/bash

set -u

joplin_ver="${1}"
docker_file="${2}"
joplin_digest_file="docker-file-digest.json"
joplin_detect_file="docker-file-detect.json"

if [[ -z "${joplin_ver}" ]]; then
	echo "Missing joplin version as first argument to this script.  Exiting"
	exit 1
fi

if [[ -z "${docker_file}" ]]; then
	echo "Missing joplin Dockerfile.server as second argument to this script.  Exiting"
	exit 1
fi

if [[ ! -f "${docker_file}" ]]; then
	echo "Docker file not found on filesystem: ${docker_file}.  Exiting"
	exit 1
fi

apt update
apt --yes install coreutils jq

digest=$(sha384sum "${dockerfile}" | cut -f1 -d' ')

if [[ -z "${digest}" -a "${#digest}" -ne 96 ]]; then
	echo "Unable to get digest for Docker file: ${docker_file}.  Exiting"
	exit 1
fi

if [[ ! -f "${joplin_digest_file}" ]]; then
	echo '{}' > "${joplin_digest_file}"
	echo '{}' > "${joplin_detect_file}"
fi

jq --arg "${joplin_ver}" "${digest}" '. += $ARGS.named' "${joplin_digest_file}" > digest-next.json
mv digest-next.json "${joplin_digest_file}"

d=$(date +%Y%m%d_%H%M%S)
jq --arg "${joplin_ver}" "${d}" '. += $ARGS.named' "${joplin_detect_file}" > detect-next.json
cp detect-next.json "${joplin_detect_file}"
