#!/bin/sh
# This is a wrapper entrypoint script for fixuid
echo "setting $(id)"
eval $( fixuid -q )
"$@"
