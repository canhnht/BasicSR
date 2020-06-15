#!/bin/bash

# Check quality of JPEG
find ./ -name '*.jpg' -exec identify -format '%Q\n' "{}"  \;

# Check image size
find ./ -name '*.png' -exec identify -format '%wx%h\n' "{}"  \;

# Convert JPEG to PNG
find -name '*.jpg' -print0 | xargs -0 -r mogrify -format png

# Move files
find ./src -name '*.png' -exec mv "{}" ./dest \;

# Count files
find . -type f | wc -l
find . -type f -name '*.png' | wc -l

# Remove random n files
find ./ -maxdepth 1 -type f -name "*.png" -print0 | sort -z -R | head -z -n 1000 | xargs -0 rm

# Move random n files
find ./train-tiles/ -maxdepth 1 -type f -name "*.png" -print0 | sort -z -R | head -z -n 10000 | xargs -0 mv -t ./val-tiles/
