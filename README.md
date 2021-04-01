# BashScripts
Various Bash Scripts that make life easier for me

createJFile.sh - a script designed to automatically start java files. 
Can make class files (with or without the standard main class), interfaces, 
and abstract classes.

createMakefile.sh - a script designed to automatically scan the path for 
java files, and create a Makefile. Automatically scans java files for main 
method to determine main, but can also be manually entered using -m option. 
Java files that have the word "test" or "Test" in them will be considered as 
part of a testBench and a "test" target will be created. This test target will 
be converted to compile with junit parameters if junit.jar is contained in the path.

goto.sh - a script that saves directories (bookmarks them), so that you don't have to 
cd/foo/bar/barfoo/food/godPlsStop/Here to get somewhere more than once - after saving to goto 
you could just use "goto god" (or whatever you named it using goto -a <name> and boom you are there. 
Supports clearing, removal, and directory change after addition. Creates a hidden file in the home 
directory to save gotos for future terminal occurances.

jAnalyzer.sh - Scans a given java file and prints out all methods that are accessible (public or 
protected). This includes internal classes that are public classes with public methods (will list 
methods as Class.method()).
