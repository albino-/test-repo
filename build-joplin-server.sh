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

cd "${joplin_repo}"
../../detect-dockerfile-changes.py --joplin-ver "${joplin_release}" --docker-file "Dockerfile.server" --json-file "../../meta.json"
if [[ "${?}" -ne 0 ]]; then
	echo "joplin version already detected or Dockerfile checksum did not match."
	exit 1
fi
cd -

#follow docker file as closely as possible from upstream
jsbuild="southof-joplin-server-${joplin_release}"
mkdir "${jsbuild}"

echo "== Copy in all the files from the source tar.gz"
cd "${joplin_repo}"
cp --parents -r ".yarn/plugins" "../${jsbuild}/"
cp --parents -r ".yarn/releases" "../${jsbuild}/"
cp --parents -r ".yarn/patches" "../${jsbuild}/"
cp package.json "../${jsbuild}/"
cp .yarnrc.yml "../${jsbuild}/"
cp yarn.lock "../${jsbuild}/"
cp gulpfile.js "../${jsbuild}/"
cp tsconfig.json "../${jsbuild}/"
cp --parents -r "packages/turndown" "../${jsbuild}/"
cp --parents -r "packages/turndown-plugin-gfm" "../${jsbuild}/"
cp --parents -r "packages/fork-htmlparser2" "../${jsbuild}/"
install -D -t "../${jsbuild}/server" packages/server/package*.json
cp --parents -r "packages/fork-sax" "../${jsbuild}/"
cp --parents -r "packages/fork-uslug" "../${jsbuild}/"
cp --parents -r "packages/htmlpack" "../${jsbuild}/"
cp --parents -r "packages/renderer" "../${jsbuild}/"
cp --parents -r "packages/tools" "../${jsbuild}/"
cp --parents -r "packages/utils" "../${jsbuild}/"
cp --parents -r "packages/lib" "../${jsbuild}/"
cp --parents -r "packages/server" "../${jsbuild}/"

cd "../${jsbuild}/"

# - Why use the env command here?
# - Because the github runner injecting the CI variable
#   and who know what else... without this the CI variable
#   is used to make 'yarn install' act like --immutable is
#   being passed, but we don't want that behavior here.
#   see: https://github.com/yarnpkg/berry/discussions/3486#discussioncomment-1379344
echo "== Build joplin ${joplin_release} using yarn"
env -i "PATH=${PATH}" yarn config set --home enableTelemetry 0
env -i "PATH=${PATH}" BUILD_SEQUENCIAL=1 yarn install --inline-builds \
    && yarn cache clean \
    && rm -rf .yarn/berry
cd ..

jsartifact="${jsbuild}.tar.xz"
echo "== Produce joplin artifact: ${jsartifact}"
tar cfJ "${jsartifact}" "${jsbuild}"
