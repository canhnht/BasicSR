#!/bin/sh
HRforEDIT="/Volumes/YoungBuffalo/datasets/div2k-flickr/sub-hr"
mkdir -p inter
mkdir -p LRjpeg
mkdir -p LRpng
mkdir -p grain
wait_for_jobs() {
  local JOBLIST=($(jobs -p))
  if [ "${#JOBLIST[@]}" -gt "$(nproc)" ]; then
    for JOB in ${JOBLIST}; do
      wait ${JOB}
    done
  fi
}
### Grain | three layers of randomised noise types
grainAdd() {

    FILENAME=$(basename -- "$file")
    FL="${FILENAME%.*}"
    GR1="${FL}_Grain_001.png"
    GR2="${FL}_Grain_002.png"
    GR3="${FL}_Grain_003.png"
    GR4="${FL}_Grain_004.png"

    nType="`shuf -e -n1 Poisson Gaussian Random`"
    nType2="`shuf -e -n1 Impulse Laplacian`"
    rType="`shuf -e -n1 Sinc Lanczos Catrom`"
    mType="`seq 1 18 | shuf -n1`"
    mType2="`seq 10 61 | shuf -n1`"
    RES1="`magick identify -format '%wx%h' ${file}`"

    magick convert -size $RES1 -resize 170% -gravity center xc:"#808080" \
    +noise ${nType} -modulate 100,${mType} -level 6%,1.3,94%  \
    -blur 0x0.24 -filter ${rType} -resize $RES1  grain/${GR1} &&

    magick convert -size $RES1 -gravity center xc:"#808080" -resize 63% \
    +noise ${nType} +noise ${nType2} -modulate 98,${mType2} \
    -resize $RES1 grain/${GR2} &&

    magick convert -size $RES1 -gravity center xc:"#808080" -resize 160% \
    +noise ${nType} +noise ${nType2} -modulate 98,${mType2} \
    -resize $RES1 grain/${GR3} &&

    magick composite -compose Overlay grain/${GR1} grain/${GR2} grain/${GR3} \
    grain/${GR4}
}
blurComposite() {
    FILENAME=$(basename -- "$file")
    FL="${FILENAME%.*}"
    BR1="${FL}_Brain_001.png"
    bLUR="`seq 0.40 0.1 3.3 | shuf -n1`"
    dISSOLVE="`seq 0.0 0.1 3 | shuf -n1`"
    grainAdd &&
    echo -e Noise level: ${dISSOLVE} &&
    echo -e "\e[96m"Blur level: ${bLUR}"\e[39m" &&
    magick convert $file -gaussian-blur 0x$bLUR grain/${BR1} &&
    magick composite -dissolve ${dISSOLVE} grain/${GR4} grain/${BR1} \
    -define png:color-type=2 inter/$OG
}
jpeg() {
    FILENAME=$(basename -- "$file")
    FL="${FILENAME%.*}"
    OP=$FL.jpeg
    cType1="`seq 40 78 | shuf -n1`"
    blurComposite &&
    echo -e "\e[92m"Compression level: ${cType1}"\e[39m" &&
    magick convert inter/$OG -sampling-factor 4:1:0 -strip \
    -define jpeg:dct-method=float -colorspace RGB -quality ${cType1} LRjpeg/$OP &&
    magick convert LRjpeg/$OP -define png:color-type=2 LRjpeg/$OG
    rm -f LRjpeg/$OP
}
png() {
    FILENAME=$(basename -- "$file")
    FL="${FILENAME%.*}"
    OG=$FL.png
    blurComposite &&
    magick convert inter/$OG -define png:color-type=2 LRpng/$OG
}
for file in HRforEDIT/*.png
    do
        FILENAME=$(basename -- "$file")
        EX="${FILENAME##*/}"
        FL="${FILENAME%.*}"
        OG=$FL.png
        OP=$FL.jpeg
        RES1="`magick identify -format '%wx%h' ${file}`"
        RNG="`seq 1 100 | shuf | head -n1`"
        if [[ RNG -gt 92 ]]
            then
            echo -e "\e[95m"Jpeg"\e[39m"
            jpeg &
            wait_for_jobs
            else
            echo -e "\e[94m"Png"\e[39m"
            png &
            wait_for_jobs
        fi
    done
    mkdir LR2
    find LRjpeg -name '*.png' -exec mv "{}" LR2/ \;
    find LRpng -name '*.png' -exec mv "{}" LR2 \;
    rm -r inter
    rm -r grain
