#! /bin/bash

file=/home/bito/class_schedule
DISPLAY=":0.0"
XDG_RUNTIME_DIR="/run/user/1000"
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
export XDG_RUNTIME_DIR=/run/user/1000 notify-send --urgency=critical  "let's have some tea :)"
notify-send "testing"
echo "$DBUS_SESSION_BUS_ADDRESS"
current_day=$(date +%a)
current_time=$(date +%H:%M)

while IFS= read -r line; do
    day=$(echo $line | awk '{print $1}')
    class_time=$(echo $line | awk '{print $2}')
    class_name=$(echo $line | awk '{print $3}') 
    # Extract hours and minutes from the current_time
    current_hour=$(echo $class_time | cut -d':' -f1)
    current_minute=$(echo $class_time | cut -d':' -f2)
    current_total_minutes=$((current_hour * 60 + current_minute))
    min_time=$((current_total_minutes - 15))
    new_hour=$((min_time / 60))
    new_minute=$((min_time % 60))
    # Format new time as HH:MM
    new_time=$(printf "%02d:%02d" $new_hour $new_minute)
    if [ "$current_day $current_time" = "$day $new_time" ]; then
      notify-send "Hey Harshita! it's time to go to $class_name class"
    fi
done < $file
