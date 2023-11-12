#!/bin/bash

REPO_PATH='/data/data/com.termux/files/home/repo/kerszl.github.io/'
if [ $# -le 0 ]; then
echo parametr to wpis do gita
exit
fi

cd $REPO_PATH
git pull
git add .         
git commit -m $1
git push

