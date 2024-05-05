#!/bin/bash

REPO_PATH='/data/data/com.termux/files/home/repo/kerszl.github.io/'
if [ $# -le 0 ]; then
echo parametr to wpis do gita
exit
fi

cd "$REPO_PATH"
echo git pull
git pull
echo git add .
git add .         
echo git commit ...
git commit -m $1
echo git push
git push

