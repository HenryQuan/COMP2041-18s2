#!/bin/sh
rm -rf .legit
if [ $? == 0 ]; then
  echo .legit removed
else
  echo Failed to remove .legit
fi