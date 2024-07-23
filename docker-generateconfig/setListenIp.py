#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import re
import yaml
import json

# load .env vars
envVars = dict()
if os.path.exists('.env') and os.path.getsize('.env') > 0:
    with open('.env') as file:
        for line in file:
            if line.startswith('#') or not line.strip():
                continue
            key, value = line.strip().split('=', 1)
            value = value.replace('"', '')
            if key in envVars:
                print(f"WARNING: dublicate key={key} in env file='.env'")
            envVars[key] = value
else:
    print(f"ERROR: file='.env' not found or size=0")
    exit(1)

#print(f"DEBUG: envVars={json.dumps(envVars,indent=4)}")

inputYamlFile = sys.argv[1]
outputYamlFile = sys.argv[2]
externalListenHosts = envVars.get('EXTERNAL_LISTEN_HOSTS', '127.0.0.1').split()
externalListenHost = envVars.get('EXTERNAL_LISTEN_HOST', None)
if externalListenHost:
    externalListenHosts = [externalListenHost]

print(f"DEBUG: externalListenHosts={externalListenHosts}")
print(f"DEBUG: externalListenHost={externalListenHost}")
listenHosts = list()
for host in externalListenHosts:
    if host not in listenHosts:
        listenHosts.append(host)

print(f"DEBUG: listenHosts={listenHosts}")

# read input yaml file
with open(inputYamlFile, 'r') as file:
    config = yaml.load(file,Loader=yaml.Loader)

# processing addresses for nodes
for index, nodes in enumerate(config['nodes']):
    listenHost = nodes['addresses'][0].split(':')[0]
    listenPort = nodes['addresses'][0].split(':')[1]
    nodeListenHosts = [listenHost] + listenHosts
    for nodeListenHost in nodeListenHosts:
        listenAddress = nodeListenHost +':'+ str(listenPort)
        if listenAddress not in nodes['addresses']:
            nodes['addresses'].append(listenAddress)
        # add "quic" listen address
        for name,value in envVars.items():
            if re.match(r"^(ANY_SYNC_.*_PORT)$", name) and value == listenPort:
                if re.match(r"^(ANY_SYNC_.*_QUIC_PORT)$", name):
                    # skip port, if PORT == QUIC_PORT
                    continue
                quicPortKey = name.replace('_PORT', '_QUIC_PORT')
                quicPortValue = envVars[quicPortKey]
                quicListenAddress = 'quic://'+ nodeListenHost +':'+ str(quicPortValue)
                if ( quicPortValue ) and ( quicListenAddress not in nodes['addresses']):
                    nodes['addresses'].append(quicListenAddress)

# write output yaml file
with open(outputYamlFile, 'w') as file:
    yaml.dump(config, file)
