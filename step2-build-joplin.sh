#!/bin/bash

set -u -e

# example dl file: https://github.com/laurent22/joplin/archive/refs/tags/v2.12.19.tar.gz

joplin_release=$(curl -s -L "https://api.github.com/repos/laurent22/joplin/releases/latest" | grep -Po '"tag_name": ?"v\K.*?(?=")')
joplin_release_dl="https://github.com/laurent22/joplin/archive/refs/tags/v${joplin_release}.tar.gz"
joplin_targz="joplin-release.tar.gz"

echo "== Building joplin release: ${joplin_release}"

mkdir build-joplin
cd build-joplin

curl -s -L -o "${joplin_targz}" "${joplin_release_dl}"
tar xf "${joplin_targz}"
rm "${joplin_targz}"

joplin_repo=$(ls -1)
mkdir build

#follow docker file as closely as possible from upstream
echo "== Copy in all the files from the source tar.gz"
cd "${joplin_repo}"
cp --parents -r ".yarn/plugins" ../build/
cp --parents -r ".yarn/releases" ../build/
cp --parents -r ".yarn/patches" ../build/
cp package.json ../build/
cp .yarnrc.yml ../build/
cp yarn.lock ../build/
cp gulpfile.js ../build/
cp tsconfig.json ../build/
cp --parents -r "packages/turndown" ../build/
cp --parents -r "packages/turndown-plugin-gfm" ../build/
cp --parents -r "packages/fork-htmlparser2" ../build/
install -D -t ../build/server packages/server/package*.json
cp --parents -r "packages/fork-sax" ../build/
cp --parents -r "packages/fork-uslug" ../build/
cp --parents -r "packages/htmlpack" ../build/
cp --parents -r "packages/renderer" ../build/
cp --parents -r "packages/tools" ../build/
cp --parents -r "packages/utils" ../build/
cp --parents -r "packages/lib" ../build/
cp --parents -r "packages/server" ../build/

cd ../build

echo "== Build joplin using yarn"
#yarn set version 3.6.0
#yarn set version '3.x'
#yarn --version
#yarn config set --home enableTelemetry 0
#BUILD_SEQUENCIAL=1 yarn install --immutable --inline-builds \
#    && yarn cache clean \
#    && rm -rf .yarn/berry
