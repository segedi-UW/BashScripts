#!/bin/bash
#################################################
# This script automatically creates a java class or interface file (standard format)

# Author: Anthony Segedi
# Email: aj.segedi@gmail.com

##################################
# Creates a java class or interface as described by the options
############### Directions ########################
# Use an alias to easily use
# In your ~/.bashrc file put the line: 'source ~/.customBashCmds', 
# (you need to create this file, named to whatever as long as it is consistent)
# Then in the ~/.customBashCmds file put the line 'alias cjf="~/scripts/createJFile.sh"'
# (or whatever the path to this script is. I put mine in a scripts directory)
#####################################################
type="class"
if [ "$#" -ge 1 ]
then
	if [ "$1" = "-h" ]
	then
		# Help option
		echo -e "cjc ( -i | -m | -a ) <name>\ncjc -h\n\n-h help\n-i interface (default is class)\n-m include main method in default (class)\n-a abstract class (default is class)"
		exit 1
	fi
	if [ -z "$2" ]
	then
		# If there is no second arg
		isMain=false
		name="$1"
	else
		# There is a second arg
		if [ "$1" = "-m" ]
		then
			# Add main class
			isMain=true
		elif [ "$1" = "-i" ]
		then
			# Change to interface
			type="interface"
		elif [ "$1" = "-a" ]
		then
			# Change to abstract class
			type="abstract class"
		else
			# Invalid option
			echo "Invalid option argument: $1 is not an option."
			exit 1
		fi
		name="$2"
	fi
else
	echo "Required arguments: <name>. Use \"cjc -h\" for help."
	exit 1
fi
classPrint="public $type $name {\n"
if [ "$isMain" = true ]
then
	classPrint+="\tpublic static void main(String[] args) {\n\t\t// TODO: Implement main method\n\t}"
fi
classPrint+="\n}"
# Check if the file is being overidden
if [ -f "$PWD/$name.java" ]
then
	read -p "Would you like to overwrite $name.java? (y/n): " force
	if [ $force != "y" ]
	then
		exit 0
	fi
fi
echo -e "$classPrint">"$PWD/$name.java"
