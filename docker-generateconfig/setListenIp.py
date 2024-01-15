#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import yaml

listenHost = sys.argv[1]
yamlFile = sys.argv[2]

with open(yamlFile, 'r') as file:
    config = yaml.load(file,Loader=yaml.Loader)

for index, nodes in enumerate(config['nodes']):
    addresses = nodes['addresses']
    port = addresses[0].split(':')[1]
    listenAddress = listenHost +':'+ port
    if listenAddress not in addresses:
        addresses.append(listenAddress)

with open(yamlFile, 'w') as file:
    yaml.dump(config, file)
