#!/bin/bash

clear() {
	file=$1
	echo "clear $file"
	if [ -d "$file" -o -f "$file" ]; then
		rm -rf $file
	fi
}

echo "check user"
if [ "$(whoami)" != "root" ]; then
	echo "ERROR: Permission denied"
	exit 1
fi

echo "check args[1]"
gzfile="$1"
if [[ ! "$gzfile" =~ ".tar.gz" ]]; then
	echo "Usage: ./go-instlal.sh <file>.tar.gz"
	exit 2
fi

clear /tmp/go
echo "ungzip and untar"
tar -zxf $gzfile -C /tmp

echo "get version"
if [ -f "/tmp/go/VERSION" ]; then
	version="$(sed 's/[^0-9.]//g' /tmp/go/VERSION)"
else
	echo "ERROR: '/tmp/go/VERSION': No such file or directory"
	exit 3
fi

echo "check version"
if [ "$version" == "" ]; then
	echo "ERROR: version="
	exit 4
fi

echo "version=$version"

SHARE="/usr/local/share/go-$version"
DOC="/usr/local/share/doc/golang-${version}-doc"
LIB="/usr/local/lib/go-$version"
BIN="/usr/local/bin"

clear $SHARE
echo "create $SHARE"
mv /tmp/go $SHARE
cd $SHARE/.. && ln -fs go-$version go

clear $DOC
echo "create $DOC"
mkdir -p $DOC
mv $SHARE/favicon.ico $DOC
mv $SHARE/doc $DOC/html

clear $LIB
echo "create $LIB"
mkdir -p $LIB
mv $SHARE/VERSION $LIB
mv $SHARE/bin $LIB
mv $SHARE/pkg $LIB
mkdir -p $SHARE/pkg
mv $LIB/pkg/include $SHARE/pkg
cd $LIB/pkg && ln -fs ../../../share/go-${version}/pkg/include .
cd $LIB && ln -fs ../../share/doc/golang-1.16-doc/html doc \
	&& ln -fs ../../share/go-${version}/api . \
	&& ln -fs ../../share/go-${version}/misc . \
	&& ln -fs ../../share/go-${version}/src . \
	&& ln -fs ../../share/go-${version}/test .
cd $LIB/.. && ln -fs go-$version go

echo "create $BIN/go $BIN/gofmt"
cd $BIN && ln -fs ../lib/go-${version}/bin/* .

echo "done"
