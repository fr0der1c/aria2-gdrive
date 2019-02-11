#!/usr/bin/env bash

GID="$1";
FileNum="$2";
File="$3";
MinSize="5"  #限制最低上传大小，默认5k
MaxSize="157286400"  #限制最高文件大小(单位k)，默认15G
RemoteDIR="/data/GoogleDrive/";  #rclone挂载的本地文件夹，最后面保留/
LocalDIR="/data/Download/";  #Aria2下载目录，最后面保留/

if [[ -z $(echo "$FileNum" |grep -o '[0-9]*' |head -n1) ]]; then FileNum='0'; fi
if [[ "$FileNum" -le '0' ]]; then exit 0; fi
if [[ "$#" != '3' ]]; then exit 0; fi

function LoadFile(){
  IFS_BAK=$IFS
  IFS=$'\n'
  if [[ ! -d "$LocalDIR" ]]; then return; fi
  if [[ -e "$File" ]]; then
    FileLoad="${File/#$LocalDIR}"
    while true
      do
        if [[ "$FileLoad" == '/' ]]; then return; fi
        echo "$FileLoad" |grep -q '/';
        if [[ "$?" == "0" ]]; then
          FileLoad=$(dirname "$FileLoad");
        else
          break;
        fi;
      done;
    if [[ "$FileLoad" == "$LocalDIR" ]]; then return; fi
    EXEC="$(command -v mv)"
    if [[ -z "$EXEC" ]]; then return; fi
    Option=" -f";
    cd "$LocalDIR";
    if [[ -e "$FileLoad" ]]; then
      ItemSize=$(du -s "$FileLoad" |cut -f1 |grep -o '[0-9]*' |head -n1)
      if [[ -z "$ItemSize" ]]; then return; fi
      if [[ "$ItemSize" -le "$MinSize" ]]; then
        echo -ne "\033[33m$FileLoad \033[0mtoo small to spik.\n";
        return;
      fi
      if [[ "$ItemSize" -ge "$MaxSize" ]]; then
        echo -ne "\033[33m$FileLoad \033[0mtoo large to spik.\n";
        return;
      fi
      eval "${EXEC}${Option}" \'"${FileLoad}"\' "${RemoteDIR}";
      if [[ $? == '0' ]]; then
        rm -rf "$FileLoad";
      fi
    fi
  fi
  IFS=$IFS_BAK
}
LoadFile;