#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import json
import requests
import re
from jinja2 import Environment, FileSystemLoader

cfg = {
    'inputEnvFile': '.env.common',
    'overrideEnvFile': '.env.override',
    'outputEnvFile': '.env',
    'templateComposeFile': 'docker-compose.yml.j2',
    'outputComposeFile': 'docker-compose.yml',
    'overrideVarMap': {
        'ANY_SYNC_NODE_VERSION': 'pkg::any-sync-node',
        'ANY_SYNC_FILENODE_VERSION': 'pkg::any-sync-filenode',
        'ANY_SYNC_COORDINATOR_VERSION': 'pkg::any-sync-coordinator',
        'ANY_SYNC_CONSENSUSNODE_VERSION': 'pkg::any-sync-consensusnode',
    },
    'versionsUrlMap': {
        'prod': 'https://puppetdoc.anytype.io/api/v1/prod-any-sync-compatible-versions/',
        'stage1': 'https://puppetdoc.anytype.io/api/v1/stage1-any-sync-compatible-versions/',
    },
}

# load variables from inputFile
envVars = dict()
if os.path.exists(cfg['inputEnvFile']) and os.path.getsize(cfg['inputEnvFile']) > 0:
    with open(cfg['inputEnvFile']) as file:
        for line in file:
            if line.startswith('#') or not line.strip():
                continue
            key, value = line.strip().split('=', 1)
            if key in envVars:
                print(f"WARNING: dublicate key={key} in env file={cfg['inputEnvFile']}")
            envVars[key] = value
else:
    print(f"ERROR: file={cfg['inputEnvFile']} not found or size=0")
    exit(1)

# override variables from overrideFile
if os.path.exists(cfg['overrideEnvFile']) and os.path.getsize(cfg['overrideEnvFile']) > 0:
    with open(cfg['overrideEnvFile']) as file:
        for line in file:
            if line.startswith('#') or not line.strip():
                continue
            key, value = line.strip().split('=', 1)
            envVars[key] = value

# api request
def apiRequest(url):
    try:
        response = requests.get(url, timeout=(3.05, 5))
        jsonResponse = response.json()
    except Exception as e:
        print(f"failed response url={url}, error={str(e)}")
        exit(1)
    if response.status_code != 200:
        print(f"failed response url={url}, status_code={response.status_code}, text={response.text}")
        exit(1)
    return jsonResponse

# get latest version
def getLatestVersions(role):
    versions = apiRequest(cfg['versionsUrlMap'][role])
    sortedVersions = dict(sorted(versions.items(), key=lambda x: int(x[0])))
    lastVersionsTimestamp, lastVersions = next(reversed(sortedVersions.items()))
    return lastVersions

# process variables
for key,value in envVars.items():
    if key in cfg['overrideVarMap'].keys():
        if value in cfg['versionsUrlMap'].keys():
            latestVersions = getLatestVersions(value)
            lastVersionKey = cfg['overrideVarMap'].get(key)
            lastVersionValue = latestVersions.get(lastVersionKey)
            if lastVersionKey and lastVersionValue:
                envVars[key] = 'v'+str(lastVersionValue)

# save in output file
with open(cfg['outputEnvFile'], 'w') as file:
    for key, value in envVars.items():
        file.write(f"{key}={value}\n")

# generate docker-compose.yml
nodes = {key.split('_')[3] for key in envVars.keys() if key.startswith('ANY_SYNC_NODE_') and key.endswith('_HOST')}
fileDevStore = 'ANY_SYNC_FILENODE_USE_DEV' in envVars
j2 = Environment(loader=FileSystemLoader('.')).get_template(cfg['templateComposeFile'])
rendered = j2.render({'nodes': nodes, 'fileDevStore': fileDevStore})
with open(cfg['outputComposeFile'], 'w') as f:
    f.write(rendered)
