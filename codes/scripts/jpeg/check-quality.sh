#!/bin/bash

find ./ -name '*.jpg' -exec identify -format '%Q\n' "{}"  \;
find -name '*.jpg' -print0 | xargs -0 -r mogrify -format png
