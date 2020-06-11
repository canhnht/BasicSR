#!/bin/bash

find ./ -name '*.jpg' -exec identify -format '%Q\n' "{}"  \;
find -name '*.jpg' -print0 | xargs -0 -r mogrify -format png
find ./src -name '*.jpg' -exec mv "{}" ./dest \;
find . -type f | wc -l
find . -type f -name '*.png' | wc -l
