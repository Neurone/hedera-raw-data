#!/bin/bash
#This Script demonstrate the usage of command line arguments in bash script

echo "Name of the script $0"
echo "There are $# arguments pass at command line"
echo "The arguments supplied are : $@"
echo " (you can also use \$*): $*"
echo
echo "With *:"
for arg in "$*"
do
echo "<$arg>"
done
echo
echo "With @:"
for arg in "$@"
do
echo "<$arg>"
done
echo
echo "The first command line argument is: $1"
echo "The PID of the script is: $$"
shift
echo "New first argument after first shift: $1"
shift
echo "New first argument after second shift: $1"
