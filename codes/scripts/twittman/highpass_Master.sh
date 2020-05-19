
# Multi-Threading
wait_for_jobs() {
    local JOBLIST=($(jobs -p))
    if [ "${#JOBLIST[@]}" -gt ${1} ]; then
        for JOB in ${JOBLIST}; do
            wait ${JOB}
        done
    fi
}
# Define Variables
read -e -p "Input Dir: " inDir
#COUNT="`ls -1q ${inDir}*.png | wc -l`"
read -e -p "Output Dir: " oDir
read -e -p "High Pass Sigma 1st: " sigma1
sigma2="bc <<< scale=6; $sigma1 * 2"
###read -e -p "High Pass Sigma 2nd: " sigma2
read -e -p "Strength of Sharpening: " strShp
read -e -p "Enter Masking Value between 0 and 10: " MASK1
mkdir -p ${oDir}
mkdir -p ".TMP"
# Higher values = more blurring before edge detection for mask, therefore less noise is mistaken for real details
maskFilter(){
    if [[ $MASK1 = 0 ]]; then
        MASKblur="0.00"
        elif [[ $MASK1 = 1 ]]; then
        MASKblur="0.70"
        elif [[ $MASK1 = 2 ]]; then
        MASKblur="1.05"
        elif [[ $MASK1 = 3 ]]; then
        MASKblur="1.4"
        elif [[ $MASK1 = 4 ]]; then
        MASKblur="1.75"
        elif [[ $MASK1 = 5 ]]; then
        MASKblur="2.10"
        elif [[ $MASK1 = 6 ]]; then
        MASKblur="2.45"
        elif [[ $MASK1 = 7 ]]; then
        MASKblur="2.80"
        elif [[ $MASK1 = 8 ]]; then
        MASKblur="3.15"
        elif [[ $MASK1 = 9 ]]; then
        MASKblur="3.50"
        elif [[ $MASK1 = 10 ]]; then
        MASKblur="3.85"
        elif [[ $MASK1 = 11 ]]; then
        MASKblur="4.2"
        elif [[ $MASK1 = 12 ]]; then
        MASKblur="4.55"
        elif [[ $MASK1 = 13 ]]; then
        MASKblur="4.9"
        else
        MASKblur="1.20"
    fi
    # If masking value is high enough, Dilate changes to Erode
    if [[ ${MASK1} -eq "1" ]]; then
        conv="Dilate"
        diskConv="3"
        blurM="3.26"
        elif [[ ${MASK1} -eq "2" ]]; then
        conv="Dilate"
        diskConv="2.65"
        blurM="2.81"
        elif [[ ${MASK1} -eq "3" ]]; then
        conv="Dilate"
        diskConv="2.20"
        blurM="2.43"
        elif [[ ${MASK1} -eq "4" ]]; then
        conv="Dilate"
        diskConv="1.7"
        blurM="2.11"
        elif [[ ${MASK1} -eq "5" ]]; then
        conv="Smooth"
        diskConv="1"
        blurM="1.85"
        elif [[ ${MASK1} -eq "6" ]]; then
        conv="Erode"
        diskConv="1.2"
        blurM="1.24"
        level2="85"
        elif [[ ${MASK1} -eq "7" ]]; then
        conv="Erode"
        diskConv="2.6"
        blurM="1"
        level2="90"
        elif [[ ${MASK1} -eq "8" ]]; then
        conv="Erode"
        diskConv="3"
        blurM="1.24"
        level2="95"
        elif [[ ${MASK1} -eq "9" ]]; then
        conv="Erode"
        diskConv="4.4"
        blurM="1.24"
        level2="100"
        elif [[ ${MASK1} -eq "10" ]]; then
        conv="Erode"
        diskConv="4.9"
        blurM="0.80"
        level2="98"
        elif [[ ${MASK1} -eq "11" ]]; then
        conv="Erode"
        diskConv="5.6"
        blurM="0.74"
        level2="96"
        elif [[ ${MASK1} -eq "12" ]]; then
        conv="Erode"
        diskConv="6.3"
        blurM="0.60"
        level2="92"
        elif [[ ${MASK1} -eq "0" ]]; then
        conv="Dilate"
        diskConv="24"
        blurM="18"
        level2="90"
        else
        conv="Dilate"
        diskConv="1"
        blurM="1"
        level2="${level1}"
    fi
}

# High Pass sharpening function with Masking
highPasSharp(){
    FILENAME=$(basename -- "$file")
    FL="${FILENAME%.*}"
    rmAlpha="${FL}_removedAlpha.png"
    chMain="${FL}_channel.png"
    ch0="${FL}_channel-0.png"
    ch1="${FL}_channel-1.png"
    ch2="${FL}_channel-2.png"
    O1="${FL}_temp.png"
    O1b="${FL}_tempB.png"
    O2="${FL}.png"
    O3="${FL}_mask.png"
    MASK2=$(( $MASK1 +(4 * 4)))
    level1=$(( 155 - $MASK2 ))
    #strShp2=$(( $strShp +(1 / 2)))
    
    magick convert ${file} -blur 0x${MASKblur} -define convolve:scale='-1!' \
    -morphology Convolve Laplacian:0 -colorspace Gray -contrast-stretch 8% -statistic Mean ${MASK1}x${MASK1} \
    -morphology ${conv} disk:${diskConv} -level 0,${level2}% -negate ".TMP"/${O3} && magick mogrify -blur 0x${blurM} ".TMP"/${O3} &&
    
    magick convert ${file} -colorspace sRGB -separate ".TMP"/${chMain} &&
    
    magick convert ".TMP"/${ch0} ".TMP"/${ch1} ".TMP"/${ch2} -combine -define png:colortype=2 -depth 8 ".TMP"/${rmAlpha} &&
    
    magick convert ${file} \( ".TMP"/${rmAlpha} -define convolve:scale='!' -bias 48% -morphology Convolve DoG:0,0,${sigma1} -alpha set -background none -channel A -evaluate Multiply ${strShp} \) -compose HardLight -composite ".TMP"/${O1b} &&
    
    magick convert ".TMP"/${O1b} \( ".TMP"/${rmAlpha} -define convolve:scale='!' -bias 48% -morphology Convolve DoG:0,0,${sigma2} -alpha set -background none -channel A -evaluate Multiply ${strShp} \) -compose HardLight -composite ".TMP"/${O1} &&
    
    magick convert ".TMP"/${O1} ${file} ".TMP"/${O3} -composite ${oDir}/${O2}
}

# Stops Sigma value going above 40
if [[ $sigma1 < 0.4 ]]; then
    sigma2="0.4"
    elif [[ $sigma1 > 40 ]]; then
    sigma2="40"
    else
    sigma2=${sigma1}
fi

# Reducing Countdown for remaining images
# reduce(){
    # COUNT=$((COUNT-1))
# }

for file in ${inDir}*.png ; do
    maskFilter && highPasSharp &
    wait_for_jobs $(nproc)
    #&& reduce && printf "\r\e[93mFiles remaining:\e[0m \e[96m${COUNT}\e[0m "
done
wait
#rm -r -f ".TMP"
