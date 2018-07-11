#!/bin/bash
#

DIR=$(dirname "$(readlink -f "$0")")
OUTPUT="dist/signal.js"

cd $DIR
#export NODE_MODULES=$(realpath "$DIR/../../node_modules")
echo "Building Signal..."

# Create bundle
browserify --extension .ls -t browserify-livescript index.ls -o $OUTPUT

echo "...build succeeded in $OUTPUT"
