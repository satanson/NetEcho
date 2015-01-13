#!/bin/bash
function abspath(){
    pushd $1 >/dev/null 2>&1
    pwd
    popd $1 >/dev/null 2>&1
}

if [ ! -e $1 ];then
    echo "$1  not exists!"
    exit 1
fi

dir=`dirname $1`
file=${1##$dir/}
dir=`abspath $dir`

base=${file%%.*}
ext=${file##*.}

if [ "x${base}x" = "x${ext}x" ];then
    ext=""
fi

newfile=$base.xml

echo "dir=$dir"
echo "file=$file"
echo "base=$base"
echo "ext=$ext"

scp $dir/$file root@centos1:~/
ssh root@centos1 "mv ~/$file ~/$newfile"
scp root@centos1:~/$newfile ./
cat $newfile
