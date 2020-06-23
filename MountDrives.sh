#!/bin/sh

declare -a drives
# Function to find all the drives that are external and fill in global array
# of drives names
FindExternalDrives () {
    drives=$(diskutil list -plist external | \
    plutil -convert json -r -o - - | \
    jq -c '[.AllDisksAndPartitions[].APFSVolumes, .AllDisksAndPartitions[].Partitions] | flatten | map(select(has("VolumeName")))[] | {volume: .VolumeName?, id: .DeviceIdentifier?}' | \
    jq -r  'select(.volume !="EFI") | .volume?')
}

{ # your 'try' block
    #Call function to find external drives
    FindExternalDrives

    echo ${drives[*]}

#   Loop through drives and mount the ones needed
    for  index in ${drives[*]}
        do
        
            #Get mount point and check if disk is mounted
            mountPoint=$(diskutil info $index | grep 'Mount Point')
            if mount | grep "on $mountPoint" > /dev/null; then
                echo "$index not mounted"
                diskutil mount $index
            else
                echo "$index mounted already"
            fi
        done

    osascript -e 'display notification  "All external disks successfully mounted"'
} || { # your 'catch' block
    osascript -e 'display notification \"Error occured mounting disks\" with title \"HDD Status\"'
}

