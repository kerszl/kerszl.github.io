#!/bin/bash

if [ $# -le 0 ]; then
echo parametr to wpis do gita
exit
fi

cd kerszl.github.io
git add .         
git commit -m $1
git push

