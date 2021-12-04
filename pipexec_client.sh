#!/bin/bash

test "$PIPE_PATH" || { echo "No PIPE_PATH specified!"; exit 1; }
test -p "$PIPE_PATH" || { echo "PIPE_PATH does not exist or is not a pipe!"; exit 1; }
test "$#" -gt 0 || { echo "No command given!"; exit 1; }

basecmd="$1"
echo "$basecmd" > "$PIPE_PATH" &
