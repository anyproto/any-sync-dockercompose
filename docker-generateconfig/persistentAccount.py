import yaml
import os
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

output_data = {}
base_dir = 'etc'
config_found = False
ids_file = 'docker-generateconfig/ids.yml'

def read_config():
    global config_found
    for root, _, files in os.walk(base_dir):
        for file in files:
            if file == 'config.yml':
                config_found = True
                config_path = os.path.join(root, file)
                directory_name = os.path.basename(root)
                try:
                    with open(config_path, 'r') as f:
                        config_data = yaml.safe_load(f)
                        account_info = config_data.get('account', {})
                        if 'any-sync-coordinator' in root:
                            network = config_data.get('network', {})
                            output_data['any-sync-coordinator'] = account_info
                            output_data['network'] = {
                                'networkId': network.get('networkId', 'unknown'),
                                'id': network.get('id', 'unknown')
                            }
                        else:
                            output_data[directory_name] = account_info
                    logging.info(f'Processed file: {config_path}')
                except Exception as e:
                    logging.error(f'Error processing file {config_path}: {e}')

    if not config_found:
        raise FileNotFoundError('etc/any-sync-*/config.yml not found. Please generate a configuration first')

    try:
        with open(ids_file, 'w') as f:
            yaml.dump(output_data, f)
        logging.info('All account and network id`s written to ids.yml')
    except Exception as e:
        logging.error(f'Error writing to ids.yml: {e}')

def write_config():
    with open(ids_file, 'r') as f:
        ids_data = yaml.safe_load(f)

    network_info = ids_data.get('network', {})

    for root, _, files in os.walk(base_dir):
        for file in files:
            if file in ('config.yml', 'network.yml', 'client.yml'):
                config_path = os.path.join(root, file)
                directory_name = os.path.basename(root)
                try:
                    with open(config_path, 'r') as f:
                        config_data = yaml.safe_load(f) or {}

                    if file == 'config.yml':
                        if directory_name in ids_data:
                            config_data['account'] = ids_data[directory_name]
                        if network_info:
                            config_data.setdefault('network', {}).update({
                                'networkId': network_info.get('networkId', 'unknown'),
                                'id': network_info.get('id', 'unknown')
                            })
                        if 'nodes' in config_data.get('network', {}):
                            for node in config_data['network']['nodes']:
                                for address in node.get('addresses', []):
                                    node_name = address.split(':')[0]
                                    if node_name in ids_data:
                                        node['peerId'] = ids_data[node_name].get('peerId', node.get('peerId', 'unknown'))

                    if file in ['network.yml', 'client.yml']:
                        if network_info:
                            config_data['networkId'] = network_info.get('networkId', 'unknown')
                        if 'nodes' in config_data:
                            for node in config_data['nodes']:
                                for address in node.get('addresses', []):
                                    node_name = address.split(':')[0]
                                    if node_name in ids_data:
                                        node['peerId'] = ids_data[node_name].get('peerId', node.get('peerId', 'unknown'))

                    with open(config_path, 'w') as f:
                        yaml.dump(config_data, f)
                    logging.info(f'Updated file: {config_path}')
                except Exception as e:
                    logging.error(f'Error processing file {config_path}: {e}')

if __name__ == "__main__":
    if os.path.exists(ids_file):
        logging.info(f'ids.yml was found! Starting to return the original accounts and network identifiers...')
        write_config()
    else:
        logging.info(f'ids.yml not found! Starting to reading current accounts and network identifiers...')
        read_config()
