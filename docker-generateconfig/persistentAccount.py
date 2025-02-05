import yaml
import os
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

BASE_DIR = 'etc'
IDS_FILE = os.path.join(BASE_DIR, 'ids.yml')

def load_yaml(file_path):
    try:
        with open(file_path, 'r') as f:
            return yaml.safe_load(f) or {}
    except Exception as e:
        logging.error(f'Error loading YAML file {file_path}: {e}')
        return {}

def save_yaml(data, file_path):
    try:
        with open(file_path, 'w') as f:
            yaml.dump(data, f)
        logging.info(f'Data saved to {file_path}')
    except Exception as e:
        logging.error(f'Error saving to {file_path}: {e}')

def process_config_file(config_path, output_data):
    directory_name = os.path.basename(os.path.dirname(config_path))
    config_data = load_yaml(config_path)

    # Extract account information
    account_info = config_data.get('account', {})

    # Handling for 'any-sync-coordinator' configurations
    if 'any-sync-coordinator' in config_path:
        network = config_data.get('network', {})
        output_data['any-sync-coordinator'] = account_info
        output_data['network'] = {
            'networkId': network.get('networkId', 'unknown'),
            'id': network.get('id', 'unknown')
        }
    else:
        output_data[directory_name] = account_info

    logging.info(f'Processed file: {config_path}')

# Extract account and network information, save the results to ids.yml
def read_config():
    output_data = {}
    config_found = False

    for root, _, files in os.walk(BASE_DIR):
        if 'config.yml' in files:
            config_found = True
            process_config_file(os.path.join(root, 'config.yml'), output_data)

    if not config_found:
        raise FileNotFoundError(f'{BASE_DIR}/any-sync-*/config.yml not found. Please generate a configuration first')

    save_yaml(output_data, IDS_FILE)

# Handles account, network, and node information updates
def update_config_file(config_path, ids_data, network_info):
    config_data = load_yaml(config_path)
    directory_name = os.path.basename(os.path.dirname(config_path))

    # Update config.yml files
    if os.path.basename(config_path) == 'config.yml':
        if directory_name in ids_data:
            config_data['account'] = ids_data[directory_name]
        if network_info:
            config_data.setdefault('network', {}).update({
                'networkId': network_info.get('networkId', 'unknown'),
                'id': network_info.get('id', 'unknown')
            })
        # Update peerId for nodes if applicable
        if 'nodes' in config_data.get('network', {}):
            for node in config_data['network']['nodes']:
                for address in node.get('addresses', []):
                    node_name = address.split(':')[0]
                    if node_name in ids_data:
                        node['peerId'] = ids_data[node_name].get('peerId', node.get('peerId', 'unknown'))

    # Update network.yml and client.yml files
    elif os.path.basename(config_path) in ['network.yml', 'client.yml']:
        if network_info:
            config_data['networkId'] = network_info.get('networkId', 'unknown')
        if 'nodes' in config_data:
            for node in config_data['nodes']:
                for address in node.get('addresses', []):
                    node_name = address.split(':')[0]
                    if node_name in ids_data:
                        node['peerId'] = ids_data[node_name].get('peerId', node.get('peerId', 'unknown'))

    save_yaml(config_data, config_path)

# Restores account and network information
def write_config():
    ids_data = load_yaml(IDS_FILE)
    network_info = ids_data.get('network', {})

    # Traverse the base directory and update relevant configuration files
    for root, _, files in os.walk(BASE_DIR):
        for file in files:
            if file in ('config.yml', 'network.yml', 'client.yml'):
                update_config_file(os.path.join(root, file), ids_data, network_info)

# retrieve node internal addresses from client.yml to send to netcheck tool
def prepare_netcheck_config(input_path: str, output_path: str):
    with open(input_path, "r") as file:
        data = yaml.safe_load(file)

    for node in data.get("nodes", []):
        if "addresses" in node:
            node["addresses"] = node["addresses"][:2]

    with open(output_path, "w") as file:
        yaml.dump(data, file, default_flow_style=False)

if __name__ == "__main__":
    # Check if ids.yml exists and decide whether to read or write configurations
    if os.path.exists(IDS_FILE):
        logging.info(f'{IDS_FILE} found! Restoring original accounts and network identifiers...')
        write_config()
    else:
        logging.info(f'{IDS_FILE} not found! Reading current accounts and network identifiers...')
        read_config()

    logging.info(f'Generate nodes.yml config for netcheck tool...')
    prepare_netcheck_config("etc/client.yml", "etc/nodes.yml")