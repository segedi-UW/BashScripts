#!/bin/bash
##############################################
# createMakefile.sh 
# Note works for java files and for junit

# Author: Anthony Segedi
# Email: aj.segedi@gmail.com

################################################
# searchs through the current directory for all .java files
# and adds them to the Makefile with appropriate syntax.
# Additionally by default searches each java file for the
# public static void main(String[] args) (or similarly equivalent)
# using a regular expression in order to determine the default
# run target in the Makefile. This can be overriden with the -m option

################# Directions ##################
# Use an alias to easily use
# In your ~/.bashrc file put the line: 'source ~/.customBashCmds', 
# (you need to create this file, named to whatever as long as it is consistent)
# Then in the ~/.customBashCmds file put the line 'alias cmake="~/scripts/createMakefile.sh"'
# (or whatever the path to this script is. I put mine in a scripts directory)
# *Note that these changes will not take effect until you restart the bash session
# or source the script folder in the current session. The instructions
# will automate that process for every future terminal session
# if followed correctly
#####
# Use cmake -h in order to figure out commands
################# Error Returns ###############
# Error return of 1 is no provided args
# Error return of 2 is invalid path
###############################################
path=$PWD
if [ "$1" = "-h" ]
then
	echo -e "cmake ( -h | -p | -m ) [mainClass]\n\nmainClass the class to run with the default command in make (when -m is used)\n-h help\n-p the path to create the makefile in and use as source\n-m class to run as main class (default searches)"
	exit 0
elif [ "$1" = "-p" ]
then
	# path option
	path=$1
fi
if ! [ -d $path ]
then
	# path is not a directory
	echo "Path provided: \"$path\", is not a valid directory."
	exit 2
fi
# Path is valid (checked)
echo "Creating Makefile in: $path"
if [ "$1" = "-m" ]
then
	# Use provided main class
	main=$2
fi
junit=false
	if ls $path | grep -q ^junit[0-9].jar 
	then
		echo "Detected junit testing. Modifying Makefile compile and run command for files with \"test|Test\" in name."
		junit=true
	fi
mapfile -t files < <( ls $path | grep .java )
makeFile="$path/Makefile"
if test -f $makeFile
then
	echo Overwrite previous Makefile?
	read -p "(y/n): " delete
	if [ "$delete" == "n" ]
	then
		exit 0
	fi
	rm $makeFile
fi
# Prints the file.class: file.java target and dependency with a compile command for java
for e in "${files[@]}"
do
	# %%.* parses for only the filename
	fileName=${e%%.*}
	
	# if no main class is defined, search for it
	if [ -z $main ]
	then
		# main has not been found yet
		mapfile -t check < <( grep "public static void main \?( \?String\[\] args \?)" "$fileName.java" )
		if [ ${#check[@]} -ge 1 ]
		then
			main=$fileName
		fi
	fi

	# Check if file is a test file
	if [[ "$fileName" =~ .*[tT]est.* ]]
	then
		# It is a test file
		testCList+="$fileName.class "
		if [ $junit = true ]
		then
			# It is a junit test file
			printList+="$fileName.class: $e\n\tjavac -cp .:junit5.jar $fileName.java\n"
		else
			# It is a normal test file
			printList+="$fileName.class: $e\n\tjavac $e\n"
			testJList+="\tjava $fileName\n"
		fi
	else
		# It is not a test file
		compileList+="$fileName.class "
		printList+="$fileName.class: $e\n\tjavac $e\n"
	fi
done
# Prints to the file
run="java $main"
if [[ -z $main ]]
then
	echo "No main method detected -> substituting run command."
	run="@echo 'Successfully compiled (TODO: Manual entry run command required)'"
fi
echo -e "run: compile\n\t$run">>$makeFile
echo "compile:" $compileList>>$makeFile
echo -en "$printList">>$makeFile
# Print tests
if [ $junit = true ]
then
	# Write special junit java run code
	echo -e "test: testCompile\n\tjava -jar junit5.jar -cp . --scan-classpath">>$makeFile
else
	# standard java test run code
	echo -en "test: testCompile\n$testJList">>$makeFile
fi
echo -e "testCompile: compile $testCList">>$makeFile
echo -en "clean:\n\trm *.class">>$makeFile
