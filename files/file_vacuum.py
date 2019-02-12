#!/usr/bin/python
# -*- coding: UTF-8 -*-
# the script is originally from https://hzy.pw/p/2475

import os
import time
from xmlrpc import client as xmlc

print("file_vacuum.py started to work. sleep 10s.", flush=True)
time.sleep(10)

rpcUrl = 'http://127.0.0.1:6800/rpc'
rpcToken = 'token:' + os.environ.get("ARIA2_RPC_SECRET")
downloadPath = '/data/Download/'  # same to aria2 config
fileWhiteList = []  # while list for deletion

s = xmlc.ServerProxy(rpcUrl)
api = s.aria2

while True:
    print('file_vacuum.py start to clean dirty files', flush=True)
    tasks = api.tellActive(rpcToken)
    tasks += api.tellStopped(rpcToken, 0, 99)
    tasks += api.tellWaiting(rpcToken, 0, 99)

    for task in tasks:
        # started BT tasks
        if ('bittorrent' in task) and ('info' in task['bittorrent']):
            filename = task['bittorrent']['info']['name']
            fileWhiteList.append(filename)
        # other tasks
        else:
            for file in task['files']:
                path = file['path']
                if path.startswith('[METADATA]'):
                    path = path.replace('[METADATA]', '')
                else:
                    path = os.path.basename(path)

                fileWhiteList.append(path)

    # del same items
    fileWhiteList = set(fileWhiteList)

    print('fileWhiteList', fileWhiteList, flush=True)


    def str_contain_list_item(string, lst):
        for item in lst:
            if item in string:
                return True
        return False


    for parent, dirnames, filenames in os.walk(downloadPath, topdown=False):
        for filename in filenames:
            path = os.path.join(parent, filename)
            if not str_contain_list_item(path, fileWhiteList):
                os.remove(path)
                print('del file: ', filename, flush=True)
        for dirname in dirnames:
            path = os.path.join(parent, dirname)
            if not str_contain_list_item(path, fileWhiteList):
                try:
                    os.rmdir(path)
                    print('del dir:  ', dirname, flush=True)
                finally:
                    pass

    time.sleep(10)
