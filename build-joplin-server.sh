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

cd "${joplin_repo}"
../detect-dockerfile-changes.sh "${joplin_release}" Dockerfile.server
cd -

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

# - Why use the env command here?
# - Because the github runner injecting the CI variable
#   and who know what else... without this the CI variable
#   is used to make 'yarn install' act like --immutable is
#   being passed, but we don't want that behavior here.
#   see: https://github.com/yarnpkg/berry/discussions/3486#discussioncomment-1379344
echo "== Build joplin using yarn"
env -i "PATH=${PATH}" yarn config set --home enableTelemetry 0
env -i "PATH=${PATH}" BUILD_SEQUENCIAL=1 yarn install --inline-builds \
    && yarn cache clean \
    && rm -rf .yarn/berry
