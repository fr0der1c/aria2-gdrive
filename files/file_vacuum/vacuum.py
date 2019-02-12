#!/usr/bin/python
# -*- coding: UTF-8 -*-
# the script is originally from https://hzy.pw/p/2475

import os
import sys
import time
from xmlrpc import client as xmlc

import logbook

rpcUrl = 'http://127.0.0.1:6800/rpc'
rpcToken = 'token:' + os.environ.get("ARIA2_RPC_SECRET")
downloadPath = '/data/Download/'  # same to aria2 config

logger = logbook.Logger(__name__)
stdout_handler = logbook.StreamHandler(stream=sys.stdout, bubble=True)
logger.handlers.append(stdout_handler)

logger.info("file_vacuum started to work.")
time.sleep(10)

s = xmlc.ServerProxy(rpcUrl)
api = s.aria2


def str_contain_set_item(string, st):
    for item in st:
        if item in string:
            return True
    return False


def vacuum():
    logger.info('file_vacuum start')
    file_whitelist = set()  # while list for deletion
    tasks = api.tellActive(rpcToken)
    tasks += api.tellStopped(rpcToken, 0, 99)
    tasks += api.tellWaiting(rpcToken, 0, 99)

    for task in tasks:
        # started BT tasks
        if ('bittorrent' in task) and ('info' in task['bittorrent']):
            filename = task['bittorrent']['info']['name']
            file_whitelist.add(filename)
        # other tasks
        else:
            for file in task['files']:
                path = file['path']
                if path.startswith('[METADATA]'):
                    path = path.replace('[METADATA]', '')
                else:
                    path = os.path.basename(path)

                file_whitelist.add(path)

    logger.info('fileWhitelist: {}'.format(file_whitelist))

    for parent, dirnames, filenames in os.walk(downloadPath, topdown=False):
        for filename in filenames:
            path = os.path.join(parent, filename)
            if not str_contain_set_item(path, file_whitelist):
                os.remove(path)
                logger.warn('del file: {}'.format(filename))
        for dirname in dirnames:
            path = os.path.join(parent, dirname)
            if not str_contain_set_item(path, file_whitelist):
                try:
                    os.rmdir(path)
                    logger.warn('del dir:  '.format(dirname))
                finally:
                    pass
        logger.info('file_vacuum end')


while True:
    vacuum()
    time.sleep(10)
