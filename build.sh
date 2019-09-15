#!/bin/bash
DIR=$(dirname "$(readlink -f "$0")")
OUTPUT="dist/signal.js"
echo "Building $OUTPUT"

# Create bundle
cd $DIR
browserify --extension .ls -t browserify-livescript index.ls -o $OUTPUT
if [[ $? == 0 ]]; then
    echo "...build succeeded in $OUTPUT"
    terser --compress --keep-fnames $OUTPUT -o "${OUTPUT%.js}-min.js"
fi
