#!/bin/sh

echo "\n=== SITUATION: NO .LEGIT FOLDER ===\n"
rm -rf .legit
touch a

echo - add without init, FAIL
./legit.pl add a
assert 0
echo 

echo commit without init, FAIL
./legit.pl commit -m "Hello World"
echo 

echo - log without init, FAIL
./legit.pl log
echo 

echo - show without init, FAIL
./legit.pl show :a
echo 

rm a
echo ===END===

echo "\n=== SITUATION: REPETITIVE INIT ===\n"

echo - first init, OK
./legit.pl init
echo

echo - repetitive init, FAIL
./legit.pl init
echo

./clean.sh > /dev/null
echo ===END===

echo "\n=== SITUATION: REPETITIVE ADD ===\n"
./legit.pl init

echo - add nothing, FAIL
./legit.pl add
echo

echo - add random non-existing file, FAIL
./legit.pl add aiufdifdjakscjds
echo

echo - add one file, OK
./legit.pl add clean.sh
echo

echo - add all files, OK
./legit.pl add *
echo

./clean.sh > /dev/null
echo ===END===

echo "\n=== SITUATION: COMMIT ===\n"
./legit.pl init

echo - no add but commit, FAIL
./legit.pl commit -m "Hello World"
echo

echo - add files and commit, OK
./legit.pl add *
./legit.pl commit -m "Hello World"
echo

echo - no changes but commit, FAIL
./legit.pl commit -m "Hello World"
echo

./clean.sh > /dev/null
echo ===END===
