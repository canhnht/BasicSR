mkdir -p LRjpeg
mkdir -p grain
mkdir -p LR2
read -e -p "Min Compression: " minCom
read -e -p "Max Compression: " maxCom
read -e -p "Min Grain: " minGrain
read -e -p "Max Grain: " maxGrain
read -e -p "Max Grain Blur: " maxBlur
read -e -p "Max Image Blur: " maxJpegBlur
read -e -p "Max Image Sharpen: " maxSharp
read -e -p "Max Image MegaSharpen: " maxMegaSharpen
MINc=$minCom
MAXc=$maxCom
MINg=$minGrain
MAXg=$maxGrain
MAXb=$maxBlur
Mbi=$maxJpegBlur
Msh=$maxSharp
SHMP=$maxMegaSharpen

wait_for_jobs() {
  local JOBLIST=($(jobs -p))
  if [ "${#JOBLIST[@]}" -gt ${1} ]; then
    for JOB in ${JOBLIST}; do
      wait ${JOB}
    done
  fi
}
#Grain simulation
GRAIN() {
    FILENAME=$(basename -- "$file")
    FL="${FILENAME%.*}"
    GR1="${FL}_Grain.png"
    GRint="${FL}_Int.png"
    GRblur="${FL}_blurred.png"
    nType="`shuf -e -n1 Poisson Gaussian Random`"
    nType2="`shuf -e -n1 Impulse Laplacian`"
    rType="`shuf -e -n1 Sinc Lanczos Catrom`"
    mType="`seq 1 18 | shuf -n1`"
    mType2="`seq 10 61 | shuf -n1`"
    dISSOLVE="`seq ${MINg} ${MAXg} | shuf -n1`"
    MGB="`seq 0 0.1 ${MAXb} | shuf -n1`"
    RES1="`magick identify -format '%wx%h' ${file}`"

    magick convert -size ${RES1} -resize 170% -gravity center xc:"#808080" \
    +noise ${nType} -modulate 100,${mType} -level 6%,94%,1.3  \
    -blur 0x0.24 -filter ${rType} -resize ${RES1}  grain/${GRint} &&

    magick convert -size ${RES1} -gravity center xc:"#808080" -resize 63% \
    +noise ${nType} +noise ${nType2} -modulate 98,${mType2} \
    -resize ${RES1} grain/${GRint} &&

    magick convert -size ${RES1} -gravity center xc:"#808080" -resize 160% \
    +noise ${nType} +noise ${nType2} -modulate 98,${mType2} \
    -resize ${RES1} grain/${GRint} &&

    magick composite -compose Overlay grain/${GRint} grain/${GRint} grain/${GRint}  \
    grain/${GRint} &&

    magick convert grain/${GRint} -gaussian-blur 0x${MGB} -depth 8 grain/${GRint} &&

    magick composite -dissolve ${dISSOLVE} grain/${GRint}  ${file} -depth 8 -define png:color-type=2 \
    LRjpeg/${GR1}
}
#Jpeg compression
JPEG(){
        FILENAME=$(basename -- "$file")
        FL="${FILENAME%.*}"
        OP=$FL.jpeg
        OG=$FL.png
        BLUR="`seq 0.01 0.01 ${GBL} | shuf -n1`"
        SHARP="`seq 0.05 0.01 ${Msh} | shuf -n1`" SHARPMEGA="`seq 1.4 0.01 ${SHMP} | shuf -n1`"
        cType="`seq ${MINc} ${MAXc} | shuf -n1`"
        RNG="`seq 1 5000 | shuf -n1`" RNG2="`seq 1 100 | shuf -n1`"
        SAM="`shuf -e -n1 "4:1:0" "4:2:0" `"
        RAD="`seq 1 50 | shuf -n1`"
        #Choose if Blur 0 or Blur Random
        if [[ $RAD -gt 10 ]]
            then
                GBL=${Mbi}
            else
                GBL="0.03"
        fi
        #Choose if Blur, Sharp or MegaSharp
        if [[ RNG -lt 1761 && RNG2 -gt 91 ]]
            then
                BLURSHARP="${SHARPMEGA}" BSG=""-"sharpen"
            elif [[ RNG -lt 1761 ]]
            then
                BLURSHARP="${SHARP}" BSG=""-"sharpen"
            else
                BLURSHARP="${BLUR}" BSG=""-"blur"
        fi
        if [[ RNG -lt 1761 && RNG2 -gt 91 ]]
            then
                BS="MegaSharpened"
            elif [[ RNG -lt 1761 ]]
            then
                BS="Sharpened"
            else
                BS="Blurred"
        fi
            #Convert to JPEG and Blur/Sharpen
            magick convert LRjpeg/${GR1} ${BSG} 0x${BLURSHARP} -sampling-factor ${SAM} -strip \
            -define jpeg:dct-method=float -colorspace RGB -quality ${cType} LRjpeg/${OP} &&
            magick convert LRjpeg/${OP} -colorspace RGB -type truecolor -depth 8 -define png:color-type=2 LR2/${OG}

    printf "
    \e[95m${file} \e[0m
    has been reduced to \e[92m${SAM}\e[0m
    \e[91m${BS}\e[0m \e[1m${BLURSHARP}\e[0m amount and
    compressed \e[93m${cType}\e[0m
    "
        }
    #Process Files
    for file in HRforEDIT/*.png
        do
            GRAIN &&
            JPEG &
        wait_for_jobs $(nproc)
        done

        wait_for_jobs 1
    rm -r -f LRjpeg
    rm -r -f grain
