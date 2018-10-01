#!/bin/sh
echo === subset 0 test 7 ===
./clean.sh
./legit.pl init
echo 1 >a
./legit.pl add a
./legit.pl commit -m message1
touch a
./legit.pl add a
./legit.pl commit -m message2
echo === END ===