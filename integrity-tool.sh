#!/bin/bash

LC_ALL=C
set -e


if [ $# != 1 ]
then
  echo "Need exactly one parameter: the directory whose integrity to check."
  exit 1
fi


DIR=`realpath $1`
INTEGRITY=.integrity
LASTSTAMP=$DIR$INTEGRITY/last
CHECKSUMS=checksums.txt
ERRORS=errors.txt

if [ ! -d "${DIR}" ]
then
  echo "Directory $1 does not exist."
  exit 1
fi

mkdir -p $DIR$INTEGRITY
touch $LASTSTAMP

# Unix epoch
THISRUN=`date +'%s'`
mkdir -p $DIR$INTEGRITY/$THISRUN

echo "This is run $THISRUN."

LASTRUN=`cat $LASTSTAMP`
if [ -z "$LASTRUN" ]
then
  echo "Last timestamp not found, assuming first run."
else
  echo "Last time checked: $LASTRUN, verifying integrity against that run."
  sha1sum --quiet -c $DIR$INTEGRITY/$LASTRUN/$CHECKSUMS >$DIR$INTEGRITY/$THISRUN/$ERRORS 2>&1 || true
  cat $DIR$INTEGRITY/$THISRUN/$ERRORS
fi

echo "Creating checksums of current state of $DIR now."
find $DIR -type f -print0 | xargs -0 sha1sum >$DIR$INTEGRITY/$THISRUN/$CHECKSUMS 2>>$DIR$INTEGRITY/$THISRUN/$ERRORS
echo $THISRUN >$LASTSTAMP

cp $0 $DIR$INTEGRITY/integrity-tool.sh 2>/dev/null || true
chmod 755 $DIR$INTEGRITY/integrity-tool.sh 2>/dev/null || true

echo "Done."
