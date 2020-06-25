
wait_for_jobs() {
    local JOBLIST=($(jobs -p))
    if [ "${#JOBLIST[@]}" -gt ${THREADS} ]; then
        for JOB in ${JOBLIST}; do
            wait ${JOB}
        done
    fi
}
read -e -p "Input Directory: " inDir
read -e -p "Divisor: " diVz
read -e -p "Input File-type: " inType
read -e -p "Threads: " THREADS
mkdir -p "_TMP"

reSize() {
    FILENAME=$(basename -- "$file")
    FL="${FILENAME%.*}"
    outFile="${FL}.png"
    RESw="`magick identify -format '%w' ${file}`"
    RESh="`magick identify -format '%h' ${file}`"
    DIFFw=$((($RESw+$diVz-1)/$diVz))
    DIFFh=$((($RESh+$diVz-1)/$diVz))
    PADw=$((($DIFFw-1)*$diVz))
    PADh=$((($DIFFh-1)*$diVz))
    DIVw=$(($RESw-$PADw))
    DIVh=$(($RESh-$PADh))
    if [[ $DIVw = $diVz ]]; then
        CROPw=${RESw}
    else
        CROPw=${PADw}
    fi
    if [[ $DIVh = $diVz ]]; then
        CROPh=${RESh}
    else
        CROPh=${PADh}
    fi
    magick convert ${file} -gravity center -crop ${CROPw}x${CROPh}+0+0 +repage +adjoin "_TMP"/${outFile}
    #printf "\n${file} Cropped to Divisor ${diVz}\n"
    printf "\n input width: ${RESw} \n Difference width: ${DIFFw} \n Padding width: ${PADw} \n Divizor Width: ${DIVw} \n crop width: ${CROPw}"
}
cLine(){
    printf -v _hr "%*s" $(tput cols) && echo ${_hr// /${1--}}
}

for file in ${inDir}*.${inType}; do
    cLine &&
    reSize &
    wait_for_jobs
done
wait