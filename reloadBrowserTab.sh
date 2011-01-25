#!/bin/bash

# Script to reload a Google Chrome browser tab with the specified URL at
# the specified reload interval
# Created Nov 30, 2010 by Reed Stoner (kaltekar@gmail.com)

tabURL="$1" 	# remember to include the trailing "/"
reloadInterval=300 					# Interval in seconds

# function to run the Applescript that reloads the Google Chrome tab.  
# The Applescript searches all the tabs in the first window for the URL 
# and then reloads that tab.
function reloadTab () {
/usr/bin/osascript << EOF
set allTabs to "fasle"
set tabID to 0
set counter to 1

tell application "Google Chrome"
	tell window 1
		repeat until allTabs = "true"
			try
				tell tab counter
					set myURL to URL
					if myURL is "$tabURL" then
						set tabID to counter
						set allTabs to "true"
					end if
					set counter to counter + 1
				end tell
			on error errmsg number errNum
				if errNum is -1719 then
					set allTabs to "true"
				end if
			end try
		end repeat
		if tabID is not 0 then
			tell tab tabID
				reload
			end tell
		end if
	end tell
end tell
EOF
}

# Trap ctrl-c to exit cleanly.
trap "echo \" Complete\"; exit 0" SIGINT SIGTERM

if [ $# -lt 1 ]; then
	echo "Usage: `basename $0` \"http://www.example.com\""
	exit 1
fi
if [ $# -gt 1 ]; then
	echo "Only one URL at a time please."
	exit 1
fi 
# Set up an infinite loop
loop=""
echo "Press Ctrl-c to exit."
until [ $loop ]; do 
	echo Reload "$tabURL"
	reloadTab
	sleep $reloadInterval
done
