#!/bin/sh

touch a

echo "\n=== SITUATION: NO .LEGIT FOLDER ===\n"
echo add without init, FAIL
./legit.pl add a
echo 

echo commit without init, FAIL
./legit.pl commit -m "Hello World"
echo 

echo log without init, FAIL
./legit.pl log
echo 

echo show without init, FAIL
./legit.pl show :a
echo 

rm a
