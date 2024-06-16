#!/usr/bin/env bash

OUTPUT=$(realpath _output)

mkdir $OUTPUT

tar -cJf "$OUTPUT/nixexprs.tar.xz" ./*.nix \
    --transform "s,^,${PWD##*/}/," \
    --owner=0 --group=0 --mtime="1970-01-01 00:00:00 UTC"

pandoc README.md -o _output/index.html