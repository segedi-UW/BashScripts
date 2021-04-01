#!/bin/bash
##################################################
# goto script

# Author: Anthony Segedi
# Email: aj.segedi@gmail.com

# Note this script creates a file in the home (~) directory to
# save goto links
# This script is most useful for headless systems,
# as shortcuts or equivalents can be used otherwise unless
# an easier interface form command line is wanted

############# Directions for use #################
# This script needs to be sourced (not ran in a subshell) for proper execution
# Use an alias to easily use
# In your ~/.bashrc file put the line: 'source ~/.customBashCmds', 
# (you need to create this file, named to whatever as long as it is consistent)
# Then in the ~/.customBashCmds file put the line 'alias goto="source ~/scripts/goto.sh"'
# (or whatever the path to this script is. I put mine in a scripts directory)

#######
# The above method can be extrapolated to other scripts. Simply add then to the .bashrc
# file (the reason for doing this is to have it automatically sourced upon entering the
# terminal environment, so the command "goto (args)" automatically works upon entering terminal)
# Note that the majority of other scripts should NOT BE SOURCED, but instead be ran as a subshell.
# This script is an exception, since a subshell would render the cd command useless. As such
# this script does not utilize exiting.
#####
# Use "goto -h" in order to figure out commands
###################################################

#Loads the file in (populates global array)
loadFile () {
	mapfile -t array< <( cat $saved )
}

#Reads the file and prints index of names (does not inclue paths)
readFile() {
	length=${#array[@]}
	for i in $(seq 0 2 $length)
	do
		if [  "$i" -eq "$length" ] || [ -z ${array[$i]} ]
		then
			break;
		fi
		echo "$i: ${array[$i]}"
	done
}
#Rewrites file
overwriteFile() {
	rm $saved
	touch $saved
	for i in ${array[@]}
	do
			echo "$i">>$saved
	done
}
#Expects one argument: name
writeToFile() {
	#Add
	echo "$1">>$saved
	echo "$PWD">>$saved
}

#check for file in home directory
saved=~/.gotoSaves
if [ -f "$saved" ]
	#if it exists load into array
then
	loadFile
else
	echo "No existing file found."
	echo "Creating new file."
	touch $saved
	declare -a array
fi
# Inputs
# Use parenthesis for comparing integers

if [ "$#" == "1" ]
then
	#single opts
	if [ "$1" == "-l" ]
	then
		#list opt
		readFile
	elif [ "$1" == "-h" ]
	then
		#help opt
		echo -e "goto ( -l | -h | -r | -c )\ngoto <name>\ngoto -a <name>\n\n-l list goto entries\n-h help\n-r remove prompts for an index from entries\n-a add entry\n-c clear all entries"
	elif [ "$1" == "-c" ]
	then
		#clear opt
		rm $saved
		touch $saved
	elif [ "$1" == "-r" ]
	then
		#remove opt
		if [ ${#array[@]} -eq 0 ]
		then
			echo "No goto entries to remove."
		else
			readFile
			read -p "Which entry should be removed? (index): " deleteIndex
			#Removal will just be replacing the element with "" (empty string), then overwriting the file
			if [ $(( deleteIndex % 2 )) == 0 ] && ((deleteIndex >= 0))
			then
				array[$deleteIndex]=""
				array[$(($deleteIndex+1))]=""
				overwriteFile
			else
				echo "Index needs to be an even number and greater than or equal to zero."
			fi
		fi
	else
		#search opt
		# Use name to find path
		# [start..end..increment]
		#${#array[@]}
		printed=false
		for i in $(seq 0 2 ${#array[@]}) 
		do
			#file format is name\npath
			if [ "${array[$i]}" == "$1" ]
			then
				cd ${array[$i + 1]}
				printed=true
				break;
			fi
		done
		if [ $printed == false ]
		then
			echo "Unlisted goto name: $1"
		fi
	fi
else
	#multi no arg cmds
	if [ "$#" == 0 ]
	then
		#No args
		echo "Requires args. Use -h for help."
	else
		#At least 2 args
		if [ "$1" == "-a" ] && ! [ -z "$2" ]
		then
			#add opt
			readarray rArray< <(grep -w $2 $saved)
			#If it is not already in the file
			if [ ${#rArray[@]} -eq 0 ] && [ $2 != "" ]
			then
				#Method call with argument
				writeToFile $2
			else
				echo "Could not add name \"$2\" is already in use."
			fi
		else
			echo "Could not add. Argument was not provided <name>"
		fi
	fi
fi
