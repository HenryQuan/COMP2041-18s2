#!/bin/sh
echo Start

max="09"
# able to run up to 100 tests, should be enough
for i in {0..9}; do
  for j in {0..9}; do
    if [ $max -eq "$i$j" ]; then
      echo Completed
      exit 0
    else
      # run tests
      echo ===$i$j===
      ./test$i$j.sh
    fi
  done
done