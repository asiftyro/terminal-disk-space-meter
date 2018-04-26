# Helper functions

# Param $1 = Foreground $2 = Background
set_color() {
    tput setaf $1
    tput setab $2
}

reset_decor() {
    tput sgr0
}

# Main function
disk_space_visual() {
    #padding top
    printf "\n\n\n"

    # Save Original IFS
    oldIFS=$IFS
    # Set IFS to split lines found from `df`
    IFS=$'\n'
    # Get lines as array
    lines=($(df))

    for((i=0; i<${#lines[@]}; i++)); do
        # Get Disk Type
        disk_type=`echo ${lines[$i]} | awk '{print $1}'`
        # Get Disk description/label
        disk_desc=`echo ${lines[$i]} | awk -F" {2,}" '{print $NF}'`
        # Take only Root disk and Volumes(if mounted)
        if [[ $disk_type == *"/dev/"* ]];then

            if [[ "$disk_desc" == "/" ]]; then
                disk_desc="Root" # Set Root drive name
            elif [[ $disk_desc == *"Volumes"* ]]; then
                disk_desc=${disk_desc//\/} # Clean backslashes
                disk_desc=${disk_desc/Volumes} # Clean the word 'Volumes'
            fi

            total=`echo ${lines[$i]} | awk '{print $2}'` # total disk space in 512-blocks
            used=`echo ${lines[$i]} | awk '{print $3}'` # used disk space in 512-blocks
            total_gb=`echo "scale=2;$total/2/1024/1024" | bc`
            used_gb=`echo "scale=2;$used/2/1024/1024" | bc`
            free_gb=`echo "scale=2;$total_gb-$used_gb" | bc`
            used_perc=$[used*100/total]
            free_perc=$[100-used_perc]

            red_meter=$[(used_perc+2-1)/2]
            green_meter=$[50-red_meter]

            # display graphics
            reset_decor
            printf " - Free:%7sGB%3s%% " $free_gb $free_perc

            set_color 2 0
            printf "%0.s=" $(seq 1 $green_meter)

            set_color 1 0
            printf "%0.s=" $(seq 1 $red_meter)
            
            reset_decor
            printf " Used:%7sGB%3s%% - " $used_gb $used_perc

            meter_label=" "$disk_desc" : "$total_gb" GB "
            meter_label_length=${#meter_label}
            printf "\n"
            printf "%0.s " {1..20}
            
            printf $meter_label
            
            echo
            echo
            echo
        fi
    done
    # Reset IFS to Original
    IFS=$oldIFS
}
