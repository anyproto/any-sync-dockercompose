# Docker-compose for any-sync
Self-host for any-sync, designed for personal usage or for review and testing purposes.

> [!IMPORTANT]
> This image is suitable for running your personal self-hosted any-sync network for home usage.
> If you plan to self-host a heavily used any-sync network, please consider other options.

> [!WARNING]
> Before upgrading please read [Upgrade-Guide](../../wiki/Upgrade-Guide)

## Documentation
All of the documentation for this repository is located in the [Wiki](../../wiki).  
Please visit the Wiki for comprehensive guides, installation instructions and more.

## Getting Started
To get started, follow these steps:

1. **Clone the repository:**
    ```bash
    git clone https://github.com/anyproto/any-sync-dockercompose.git
    ```
2. **Navigate to the project directory:**
    ```bash
    cd any-sync-dockercompose
    ```
3. **Install the necessary dependencies:**  
    You need to install Docker and Docker Compose https://docs.docker.com/compose/install/
4. **Configuration:**
    For configuration, use the `.env.override` file.
    For example, setting an external IP for listening:
    ```
    echo 'EXTERNAL_LISTEN_HOSTS=<yourExternalIp1> <yourExternalIp2' >> .env.override
    ```
    More information can be found [here](../../wiki/Configuration).
4. **Run the project:**
    ```bash
    make start
    ```

For detailed instructions, please refer to the [Usage Guide](../../wiki/Usage) in the Wiki.

## Contribution
Thank you for your desire to develop Anytype together!

❤️ This project and everyone involved in it is governed by the [Code of Conduct](https://github.com/anyproto/.github/blob/main/docs/CODE_OF_CONDUCT.md).

🧑‍💻 Check out our [contributing guide](https://github.com/anyproto/.github/blob/main/docs/CONTRIBUTING.md) to learn about asking questions, creating issues, or submitting pull requests.

🫢 For security findings, please email [security@anytype.io](mailto:security@anytype.io) and refer to our [security guide](https://github.com/anyproto/.github/blob/main/docs/SECURITY.md) for more information.

🤝 Follow us on [Github](https://github.com/anyproto) and join the [Contributors Community](https://github.com/orgs/anyproto/discussions).

---
Made by Any — a Swiss association 🇨🇭

Licensed under [MIT](./LICENSE.md).
