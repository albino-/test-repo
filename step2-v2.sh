#!/bin/bash

echo "== PATH"
echo $PATH

set -u -e

# example dl file: https://github.com/laurent22/joplin/archive/refs/tags/v2.12.19.tar.gz

joplin_release=$(curl -s -L "https://api.github.com/repos/laurent22/joplin/releases/latest" | grep -Po '"tag_name": ?"v\K.*?(?=")')
joplin_release_dl="https://github.com/laurent22/joplin/archive/refs/tags/v${joplin_release}.tar.gz"
joplin_targz="joplin-release.tar.gz"

echo "== Building joplin release: ${joplin_release}"

mkdir build-joplin
cd build-joplin

curl -s -L -o "${joplin_targz}" "${joplin_release_dl}"
