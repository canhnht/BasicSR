#!/bin/sh
read -e -p "Min Compression: " minCom
read -e -p "Max Compression: " maxCom
MINc=$minCom
MAXc=$maxCom
mkdir LR2
wait_for_jobs() {
  local JOBLIST=($(jobs -p))
  if [ "${#JOBLIST[@]}" -gt "$(nproc)" ]; then
    for JOB in ${JOBLIST}; do
      wait ${JOB}
    done
  fi
  }
JPEG(){
    FILENAME=$(basename -- "$file")
    FL="${FILENAME%.*}"
    OG=$FL.jpeg
    cType="`seq ${MINc} ${MAXc} | shuf -n1`" 
    SAM="`shuf -e -n1 "4:1:0" "4:2:0" `"
    if [ ${2} != "0" ]
    then
        for i in {1.."${2}"}
        do
        magick convert "${1}" -sampling-factor ${SAM} -strip -define jpeg:dct-method=float -colorspace RGB -quality ${cType} LR2/temp.jpg
        magick convert LR2/temp.jpg -sampling-factor ${SAM} -strip -define jpeg:dct-method=float -colorspace RGB -quality ${cType} LR2/$OG
        rm -f LR2/temp.jpg
        echo -e "\e[36m${file} \e[92;2;4mcompressed\e[24m \e[1;93;22m"${2}" \e[0mtimes"
        done
    fi
    }
PNG(){
    FILENAME=$(basename -- "$file")
    FL="${FILENAME%.*}"
    OG=$FL.jpeg
    OP1=$FL.png
    magick convert LR2/$OG -define png:color-type=2 LR2/$OP1 
    }
for file in *.png
    do
        TMS="`seq 350 4425 | shuf | head -n1`"
        FILENAME=$(basename -- "$file")
        FL="${FILENAME%.*}"
        OG=$FL.jpeg
        OP1=$FL.png
        JPEG "${file}" "${TMS}" && PNG
    done
    wait
    