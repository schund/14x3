#!/bin/bash

# bash-script for raspberry pi with camera to make time laps photos
# need to install mathematic-library bc! "apt-get update && apt-get install bc"

log_date="$( date +%Y%m%d-%H%M )"
log_dir="/srv/logs/"
log_file="${log_dir}timelaps-${log_date}.log"
pic_dir="/mnt/user/timelaps/"

log() {
    echo "$(date +%Y.%m.%d-%H:%M:%S)" "$1" >> ${log_file};
    echo $1
}

read -p "in one word, why?: " why
dest="${pic_dir}${why}/"

if [ ! -d $pic_dir ]; then
    echo "[FAIL] mountpoint does not exist! EXIT..."
    exit
else
    if [ ! -d $dest ]; then
        echo "[ok]"
    else
        echo "[FAIL] reason already exists! EXIT..."
        exit
    fi
fi

read -p "how long would you like to capture? (min): " cap_time
echo "checking space on ${pic_dir}..."

pic_max=$(expr $cap_time \* 6)
pic_space=$(bc <<< "$pic_max*2.9" | awk -F'.' '{ print $1 }')
space_need=$(bc <<< "$pic_max*2.9*1024" | awk -F'.' '{ print $1 }')
space_left=$(df ${pic_dir} | grep ^/ | awk '{ print $4 }')

if [[ ${space_left} < ${space_need} ]]; then
    echo "[ok]"
    echo "creating directory ${why}"
    /bin/mkdir ${dest}
    if [ "$?" -ne "0" ]; then
        echo "[FAIL] could not create ${dest}! EXIT..."
        exit
    else
        echo "[ok]"
    fi
    echo "logfile will be written to ${log_file}"
else
    echo "[FAIL] not enough space on device! EXIT..."
    exit 1
fi

log "START captureing Timelaps ${why}"
log "${pic_max} files will be created as: ${dest}[xx].jpg"
log "${pic_space} MB space is needed..."


for i in $(eval echo "{1..$pic_max}"); do
    log "..4..3..2..1..smile...";
    sleep 4
    log "takeing picture number: $i"
    raspistill -o ${dest}${i}.jpg
    log "<----------------------------->"
done

log "FINISHED!"

exit 0
