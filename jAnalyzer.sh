#!/bin/bash
#################################
#jAnalyzer

# Author: Anthony Segedi
# Email: aj.segedi@gmail.com

#################################
# Analyzes java files and prints the accessible methods and constructors with comments
# Intended to be used to use objects on the command line in an easy way

#################################
# Command:
# ajava <file>

# Output:
# Constructors
# c1
# c2
#
# Methods
# m1
# m2
# m3
#
# TODO:
#Constructors (with comments)
# c1
# c2 
#
# Methods (with comments)
# m1
# m2
# m3

if [ "$#" -lt 1 ]
then
	echo "Requires arguments: <file>"
else
	if [ -f "$1" ] && [[ "$1" =~ .*\.java ]]
	then
		# File is valid and is a java file
		# Read for matches
		#
		class=${1%%.*}
		skip=false
		internal=false
		left=0
		right=0

		# While loop
		while read -r line
		do
			# echo "$line"
			if [ $skip = true ]
			then
				# skip until a matching } is found
				if [[ $line =~ \} ]]
				then
					right=$(( right+1 ))
				fi
				if [[ $line =~ \{ ]]
				then
					left=$(( left+1 ))
				fi
				if [ $left -eq $right ]
				then
					# echo "Stopping skipping"
					skip=false
				else
					# echo "Skipping"
					continue
				fi
			elif [ $internal = true ]
			then
				# Print internal until matching } is found
				if [[ $line =~ \} ]]
				then
					right=$(( right+1 ))
				fi
				if [[ $line =~ \{ ]]
				then
					left=$(( left+1 ))
				fi
				if [ $left -eq $right ]
				then
					# echo "Exiting Internal class"
					internal=false
				fi
			fi
			if [[ $line =~ public[[:space:]]class[[:space:]]$class[[:space:]] ]]
			then
				# is the regular class
				# Do nothing
				continue
			else
				# could be an internal class
				if [[ $line =~ public.class ]]
				then
					# echo "found internal class"
					# Is an internal public class
					# add the name to the method
					# turn into array
					IFS=' ' read -ra array <<< "$line"
					# grab value (should be index 2)
					internalName=${array[2]}
					# set useSubClass=true
					internal=true
					left=1
					right=0
				elif [[ $line =~ private.class ]]
				then
					# echo "found internal private class"
					# Is an internal private class.
					# Skip methods
					skip=true
					left=1
					right=0
				fi
			fi
			# See if the line contains the regex expression
			# i.e., see if the line is a public / protected method
			if [[ $line =~ public.*\(.*\)|protected.*\(.*\) ]]
			then
				# Replace bracket at end of string, if not one line 
				# (does not have both brackets)
				if ! [[ $line =~ \{.*\} ]]
				then
					line=${line/{/""}
				fi
				# The line is an appropriate method
				if [[ $line =~ public[[:space:]]$class[[:space:]]?\(.*\) ]]
				then
					# Construtor
					constructors+="$line\n\n"
				elif [ $internal = true ] && [[ $line =~ public[[:space:]]$internalName[[:space:]]?\(.*\) ]]
				then
					# Internal Constructor
					IFS=' ' read -ra array <<< "$line"
					constructors+="${array[0]} $class.${array[1]} ${array[2]}\n\n"
				else
					# Is a method
					if [ $internal = true ]
					then
						# echo "Printing internal"
						IFS=' ' read -ra array <<< "$line"
						i=$(( ${#array[@]} - 1 ))

						# Regex
						pat='^\(' 
						while [ $i -ge 0 ]
						do
							if [[ ${array[$i]} =~ \( ]]
							then
								# Parenthsis detected
								if [[ ${array[$i]} =~ $pat ]]
								then
									# Use previous index - method is not connected
									# It is disconnected
									array[$((i-1))]=$internalName.${array[$((i-1))]}
									break
								else
									# Check for if method is connected
									array[$i]=$internalName.${array[$i]}
									break
								fi
							fi
							i=$(( --i ))
						done
						methods+="${array[0]} ${array[1]} ${array[2]} ${array[3]} ${array[4]} ${array[5]}\n\n"
					else
						methods+="$line\n\n"
					fi
				fi
			fi
		done < $1
		echo -e "------------Constructors-----------\n\n$constructors"
		echo -e "--------------Methods--------------\n\n$methods"
	else
		echo "File provided was not a java file."
	fi
fi
