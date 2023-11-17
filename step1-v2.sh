#!/bin/bash

which node
which npm
node --version

echo "== yarn change version"
corepack enable
#yarn set version '3.x.x'
#yarn set version '3.x'
yarn set version '3.6.0' 
