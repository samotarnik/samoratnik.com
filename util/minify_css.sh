#!/usr/bin/env bash

set -e

# TODO: make it run from any folder...

find src/ -iname "*.css" | grep -v "\.min" | while read fname; do
	wget --post-data="input=$(cat $fname)" --output-document=src/$(basename $fname .css).min.css https://cssminifier.com/raw
done