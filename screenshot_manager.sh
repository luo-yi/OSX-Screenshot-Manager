#!/bin/bash
PATH=/usr/local/bin:/usr/local/sbin:~/bin:/usr/bin:/bin:/usr/sbin:/sbin

#-------------------------------------------------------------------------------------------------#
function get_minutes_from_now {
	# Convert current time and input time into UNIX time.
	current_unix_time=$(gdate --date="$(date '+%Y-%m-%d %H:%M:%S')" +"%s")
	input_unix_time=$(gdate --date="$1" +"%s")

	# Return the number of minutes between the two dates.
	echo $(( ($current_unix_time - $input_unix_time) / 60 ))
}

export -f get_minutes_from_now


#-------------------------------------------------------------------------------------------------#
function check_screenshot {
	# Get arguments passed to function - file name, and time limit.
	filename=$1
	time_limit=$2

	# Get created datetime from filename.
	datetime=$(echo $filename | gsed -e 's/.\/Screen Shot //g' -e 's/ at//g' -e 's/.png//g' -e 's/ ([0-9]*)//g' -e 's/\./:/g')

	# If this screenshot was created >= 30 minutes ago, move it to Screenshots directory.
	if (( $(get_minutes_from_now "$datetime") >= $time_limit )); then
		new_filename=$(echo $filename | gsed -e 's/.\/Screen Shot //g')
		mv "$filename" "Screenshots/$new_filename"
	fi
}

export -f check_screenshot


#-------------------------------------------------------------------------------------------------#
# # Change the current directory to the user's desktop.
cd ~/Desktop

# Make Screenshots directory if it doesn't already exist. 
mkdir -p "Screenshots"

# Regular expression to match the screenshot naming convention.
regex='^\./Screen\sShot\s20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]\sat\s[0-2][0-9]\.[0-5][0-9]\.[0-5][0-9].*\.png$'

# Spawn new process to run 'check_screenshot' function on any files that match the regular expression.
gfind . -maxdepth 1 -type f -regex $regex -exec /bin/bash -c 'check_screenshot "{}" 30' \;
