import os
from dotenv import load_dotenv
import logging
import time

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

load_dotenv()

def get_env_var(key, retries=3, delay=1):
    for _ in range(retries):
        value = os.getenv(key)
        if value is not None:
            return value
        time.sleep(delay)
    logging.error(f"Environment variable {key} is not set.")
    return None

env_vars = {
    'AWS_ACCESS_KEY_ID': os.getenv('AWS_ACCESS_KEY_ID'),
    'AWS_SECRET_ACCESS_KEY': os.getenv('AWS_SECRET_ACCESS_KEY'),
    'EXTERNAL_LISTEN_HOSTS': os.getenv('EXTERNAL_LISTEN_HOSTS', ''),
    'EXTERNAL_LISTEN_HOST': os.getenv('EXTERNAL_LISTEN_HOST', ''),
    'ANY_SYNC_COORDINATOR_HOST': os.getenv('ANY_SYNC_COORDINATOR_HOST'),
    'ANY_SYNC_COORDINATOR_PORT': os.getenv('ANY_SYNC_COORDINATOR_PORT'),
    'ANY_SYNC_COORDINATOR_QUIC_PORT': os.getenv('ANY_SYNC_COORDINATOR_QUIC_PORT'),
    'MONGO_CONNECT': os.getenv('MONGO_CONNECT'),
    'ANY_SYNC_COORDINATOR_DEFAULT_LIMITS_SPACE_MEMBERS_READ': os.getenv('ANY_SYNC_COORDINATOR_DEFAULT_LIMITS_SPACE_MEMBERS_READ'),
    'ANY_SYNC_COORDINATOR_DEFAULT_LIMITS_SPACE_MEMBERS_WRITE': os.getenv('ANY_SYNC_COORDINATOR_DEFAULT_LIMITS_SPACE_MEMBERS_WRITE'),
    'ANY_SYNC_COORDINATOR_DEFAULT_LIMITS_SHARED_SPACES_LIMIT': os.getenv('ANY_SYNC_COORDINATOR_DEFAULT_LIMITS_SHARED_SPACES_LIMIT'),
    'ANY_SYNC_CONSENSUSNODE_HOST': os.getenv('ANY_SYNC_CONSENSUSNODE_HOST'),
    'ANY_SYNC_CONSENSUSNODE_PORT': os.getenv('ANY_SYNC_CONSENSUSNODE_PORT'),
    'ANY_SYNC_CONSENSUSNODE_QUIC_PORT': os.getenv('ANY_SYNC_CONSENSUSNODE_QUIC_PORT'),
    'ANY_SYNC_FILENODE_HOST': os.getenv('ANY_SYNC_FILENODE_HOST'),
    'ANY_SYNC_FILENODE_PORT': os.getenv('ANY_SYNC_FILENODE_PORT'),
    'ANY_SYNC_FILENODE_QUIC_PORT': os.getenv('ANY_SYNC_FILENODE_QUIC_PORT'),
    'MINIO_BUCKET': os.getenv('MINIO_BUCKET'),
    'REDIS_URL': os.getenv('REDIS_URL'),
    'ANY_SYNC_FILENODE_DEFAULT_LIMIT': os.getenv('ANY_SYNC_FILENODE_DEFAULT_LIMIT'),
    'ANY_SYNC_NODE_1_HOST': os.getenv('ANY_SYNC_NODE_1_HOST'),
    'ANY_SYNC_NODE_1_PORT': os.getenv('ANY_SYNC_NODE_1_PORT'),
    'ANY_SYNC_NODE_1_QUIC_PORT': os.getenv('ANY_SYNC_NODE_1_QUIC_PORT'),
    'ANY_SYNC_NODE_2_HOST': os.getenv('ANY_SYNC_NODE_2_HOST'),
    'ANY_SYNC_NODE_2_PORT': os.getenv('ANY_SYNC_NODE_2_PORT'),
    'ANY_SYNC_NODE_2_QUIC_PORT': os.getenv('ANY_SYNC_NODE_2_QUIC_PORT'),
    'ANY_SYNC_NODE_3_HOST': os.getenv('ANY_SYNC_NODE_3_HOST'),
    'ANY_SYNC_NODE_3_PORT': os.getenv('ANY_SYNC_NODE_3_PORT'),
    'ANY_SYNC_NODE_3_QUIC_PORT': os.getenv('ANY_SYNC_NODE_3_QUIC_PORT'),
}

external_hosts = []

if env_vars['EXTERNAL_LISTEN_HOST']:
    external_hosts.append(env_vars['EXTERNAL_LISTEN_HOST'])

if env_vars['EXTERNAL_LISTEN_HOSTS']:
    external_hosts.extend(env_vars['EXTERNAL_LISTEN_HOSTS'].split(' '))

external_hosts = [host.strip() for host in external_hosts if host.strip()]

template = f"""
external-addresses:
"""

for host in external_hosts:
    template += f" - {host}\n"

template += f"""
any-sync-coordinator:
  listen: {env_vars['ANY_SYNC_COORDINATOR_HOST']}
  yamuxPort: {env_vars['ANY_SYNC_COORDINATOR_PORT']}
  quicPort: {env_vars['ANY_SYNC_COORDINATOR_QUIC_PORT']}
  mongo:
    connect: {env_vars['MONGO_CONNECT']}
    database: coordinator
  defaultLimits:
    spaceMembersRead: {env_vars['ANY_SYNC_COORDINATOR_DEFAULT_LIMITS_SPACE_MEMBERS_READ']}
    spaceMembersWrite: {env_vars['ANY_SYNC_COORDINATOR_DEFAULT_LIMITS_SPACE_MEMBERS_WRITE']}
    sharedSpacesLimit: {env_vars['ANY_SYNC_COORDINATOR_DEFAULT_LIMITS_SHARED_SPACES_LIMIT']}

any-sync-consensusnode:
  listen: {env_vars['ANY_SYNC_CONSENSUSNODE_HOST']}
  yamuxPort: {env_vars['ANY_SYNC_CONSENSUSNODE_PORT']}
  quicPort: {env_vars['ANY_SYNC_CONSENSUSNODE_QUIC_PORT']}
  mongo:
    connect: {env_vars['MONGO_CONNECT']}/?w=majority
    database: consensus

any-sync-filenode:
  listen: {env_vars['ANY_SYNC_FILENODE_HOST']}
  yamuxPort: {env_vars['ANY_SYNC_FILENODE_PORT']}
  quicPort: {env_vars['ANY_SYNC_FILENODE_QUIC_PORT']}
  s3Store:
    endpoint: http://minio:9000
    bucket: {env_vars['MINIO_BUCKET']}
    indexBucket: {env_vars['MINIO_BUCKET']}
    region: us-east-1
    profile: default
    forcePathStyle: true
  redis:
    url: {env_vars['REDIS_URL']}
  defaultLimit: {env_vars['ANY_SYNC_FILENODE_DEFAULT_LIMIT']}

any-sync-node:
  listen:
  - {env_vars['ANY_SYNC_NODE_1_HOST']}
  - {env_vars['ANY_SYNC_NODE_2_HOST']}
  - {env_vars['ANY_SYNC_NODE_3_HOST']}
  yamuxPort:
  - {env_vars['ANY_SYNC_NODE_1_PORT']}
  - {env_vars['ANY_SYNC_NODE_2_PORT']}
  - {env_vars['ANY_SYNC_NODE_3_PORT']}
  quicPort:
  - {env_vars['ANY_SYNC_NODE_1_QUIC_PORT']}
  - {env_vars['ANY_SYNC_NODE_2_QUIC_PORT']}
  - {env_vars['ANY_SYNC_NODE_3_QUIC_PORT']}
"""

missing_vars = [key for key, value in env_vars.items() if value is None]
if missing_vars:
    logging.critical(f"Missing environment variables: {', '.join(missing_vars)}")
    raise SystemExit(1)

logging.info("All environment variables loaded successfully.")

os.makedirs("etc", exist_ok=True)

with open("etc/defaultTemplate.yml", "w") as file:
    file.write(template)
    logging.info("Template for `any-sync-network` written to ./etc/defaultTemplate.yml")

with open("etc/awsCredentials", "w") as aws_file:
    aws_file.write(f"[default]\naws_access_key_id={get_env_var('AWS_ACCESS_KEY_ID')}\naws_secret_access_key={get_env_var('AWS_SECRET_ACCESS_KEY')}\n")
    logging.info("AWS credentials file written to ./etc/awsCredentials")
