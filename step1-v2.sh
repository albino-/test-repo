#!/bin/bash

hash -r

echo "== node path"
which node
echo "== node version"
node --version

echo "== npm path"
which npm
echo "== npm version"
npm --version

echo
echo "== yarn change version"
corepack enable
#yarn set version '3.x.x'
#yarn set version '3.x'
yarn set version '3.6.0' 
