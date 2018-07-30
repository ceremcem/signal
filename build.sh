#!/bin/bash
DIR=$(dirname "$(readlink -f "$0")")
OUTPUT="dist/signal.js"
echo "Building $OUTPUT"

# Create bundle
cd $DIR
browserify --extension .ls -t browserify-livescript index.ls -o $OUTPUT
[[ $? == 0 ]] && echo "...build succeeded in $OUTPUT"
