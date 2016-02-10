#!/bin/sh
set -e
if [ $# -ne 1 ]; then
    echo usage: $0 plist-file
    exit 1
fi

plist="$1"
dir="$(dirname "$plist")"

VERSIONNUM=$(/usr/libexec/Plistbuddy -c "Print CFBundleShortVersionString" "$plist")
if [ -z "$VERSIONNUM" ]; then
    echo "No version number in $plist"
    exit 2
fi

NEWSUBVERSION=`echo $VERSIONNUM | awk -F "." '{print $3}'`
NEWSUBVERSION=$(($NEWSUBVERSION + 1))
NEWVERSIONSTRING=`echo $VERSIONNUM | awk -F "." '{print $1 "." $2 ".'$NEWSUBVERSION'" }'`
/usr/libexec/Plistbuddy -c "Set CFBundleShortVersionString $NEWVERSIONSTRING" "$plist"