#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import yaml

arguments = sys.argv[1:]
yamlFile = arguments[0]
listenHosts = arguments[1:]

with open(yamlFile, 'r') as file:
    config = yaml.load(file,Loader=yaml.Loader)

for index, nodes in enumerate(config['nodes']):
    addresses = nodes['addresses']
    port = addresses[0].split(':')[1]
    for listenHost in listenHosts:
        listenAddress = listenHost +':'+ port
        if listenAddress not in addresses:
            addresses.append(listenAddress)

with open(yamlFile, 'w') as file:
    yaml.dump(config, file)
