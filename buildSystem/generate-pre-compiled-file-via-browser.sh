#!/bin/bash

. ./buildSystem/configure-these-paths.sh

HAYSTACK=$(uname -r)
NEEDLE='microsoft' # wsl2 only works with lowercase m

URL_PARAM='?generatePreCompiled'

TO_RUN=''

if [[ "$HAYSTACK" == *"$NEEDLE"* ]]; then
   TO_RUN="$FIZZYGUM_CHROME_PATH_WINDOWS $FIZZYGUM_PAGE_PATH_WINDOWS$URL_PARAM"
   echo "rm $DOWNLOADS_DIRECTORY/pre-compiled*.zip"
   eval "rm $DOWNLOADS_DIRECTORY/pre-compiled*.zip"
   echo $TO_RUN
   eval $TO_RUN
   sleep 12
   unzip -o -d $BUILD_PATH/js/ $DOWNLOADS_DIRECTORY/pre-compiled.zip
fi