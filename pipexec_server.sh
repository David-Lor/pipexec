#!/bin/bash

test "$PIPE_PATH" || { echo "No PIPE_PATH specified!"; exit 1; }
test -p "$PIPE_PATH" || { echo "PIPE_PATH does not exist or is not a pipe!"; exit 1; }
test "$SCRIPT_PATH" || { echo "No SCRIPT_PATH specified!"; exit 1; }

if [ "$PURGE_PIPE" == "1" ]
then
    echo "Purging pipe..."
    dd if="$PIPE_PATH" iflag=nonblock of=/dev/null && echo "pipe emptied!"
fi

echo "Start listening to pipe $PIPE_PATH"
while true
do
    line=$(cat < "$PIPE_PATH")
    echo "Pipe read: $line"
    basecmd=$(echo $line | cut -f1 -d-)
    script="$SCRIPT_PATH/$basecmd"

    if [ ! -f "$script" ]
    then
        script="$script.sh"
        if [ ! -f "$script" ]
        then
            echo "Script $script not found!"
            continue
        fi
    fi

    "$script" &
    echo "Script $script ran with PID=$!"
done
