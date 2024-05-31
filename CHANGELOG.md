# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

<!-- insertion marker -->
## [v4.1.0](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v4.1.0) - 2024-05-31

<small>[Compare with v4.0.3](https://github.com/anyproto/any-sync-dockercompose/compare/v4.0.3...v4.1.0)</small>

### Added

- added Dockerfile-netcheck ([c3a7407](https://github.com/anyproto/any-sync-dockercompose/commit/c3a7407958247bb8ae12d97c8e544bda7609f999) by Grigory Efimov).

### Fixed

- fix Dockerfile-netcheck ([339bfda](https://github.com/anyproto/any-sync-dockercompose/commit/339bfda8f220a1018946d7d1b0a931aae047b409) by Grigory Efimov).

## [v4.0.3](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v4.0.3) - 2024-05-17

<small>[Compare with v4.0.2](https://github.com/anyproto/any-sync-dockercompose/compare/v4.0.2...v4.0.3)</small>

### Fixed

- fixed docker-generateconfig/setListenIp.py ([be138fa](https://github.com/anyproto/any-sync-dockercompose/commit/be138faf23b96310429b83d02d9b85f270070320) by Grigory Efimov).
- fixed README.md ([249adb5](https://github.com/anyproto/any-sync-dockercompose/commit/249adb5850c4d77c818d7702250f3c996007de9b) by Grigory Efimov).
- fix README.md ([bbd2765](https://github.com/anyproto/any-sync-dockercompose/commit/bbd27650e10cd43e35bd9eb8a1a13df706c4d411) by Grigory Efimov).
- Fix UDP ports mapping ([ea4bd98](https://github.com/anyproto/any-sync-dockercompose/commit/ea4bd985ae57c7b6793e5a3850cc1356196afe62) by CzBiX).

### Removed

- removed any-sync-admin ([7b57295](https://github.com/anyproto/any-sync-dockercompose/commit/7b57295ff34ec62306356a2726ddf63c43c7d3aa) by Grigory Efimov).
- Remove version from docker as it is deprecated ([d97f23f](https://github.com/anyproto/any-sync-dockercompose/commit/d97f23f266a52fc562c136dea6b6871a60066050) by Grigory Efimov).

## [v4.0.2](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v4.0.2) - 2024-04-26

<small>[Compare with v4.0.1](https://github.com/anyproto/any-sync-dockercompose/compare/v4.0.1...v4.0.2)</small>

### Added

- added EXTERNAL_MINIO_PORT and EXTERNAL_MINIO_WEB_PORT ([9888da2](https://github.com/anyproto/any-sync-dockercompose/commit/9888da2f607114315789698119e11e9e1dc67f05) by Grigory Efimov).

## [v4.0.1](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v4.0.1) - 2024-04-26

<small>[Compare with v4.0.0](https://github.com/anyproto/any-sync-dockercompose/compare/v4.0.0...v4.0.1)</small>

### Fixed

- Fixed the generation of QUIC protocol listening addresses ([ed0520b](https://github.com/anyproto/any-sync-dockercompose/commit/ed0520b39d2e90b1e019c978a0d86c4764f1cda9) by Grigory Efimov).

## [v4.0.0](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v4.0.0) - 2024-04-23

<small>[Compare with v3.0.0](https://github.com/anyproto/any-sync-dockercompose/compare/v3.0.0...v4.0.0)</small>

### Added

- added support prod,stage1 versions for ghcr docker images ([a9b8cfc](https://github.com/anyproto/any-sync-dockercompose/commit/a9b8cfc4295784f917ef3cf6a691da253be7fb21) by Grigory Efimov).

### Changed

- CHANGELOG.md update ([c5fb241](https://github.com/anyproto/any-sync-dockercompose/commit/c5fb241eb79a884246ff4b3ad71881c9c0fea25c) by Grigory Efimov).

## [v3.0.0](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v3.0.0) - 2024-04-05

<small>[Compare with v2.1.2](https://github.com/anyproto/any-sync-dockercompose/compare/v2.1.2...v3.0.0)</small>

### Added

- added EXTERNAL_ANY_SYNC_ADMIN_PORT ([6f1e4e7](https://github.com/anyproto/any-sync-dockercompose/commit/6f1e4e7b9fddc019745d8b479ab7c70411c0520c) by Grigory Efimov).

### Fixed

- fix replica init command ([5339177](https://github.com/anyproto/any-sync-dockercompose/commit/5339177c69f9a67d24458aab0af6d81c7148e426) by Kirill Shklyaev).
- fix status 'unhealthy' in mongo replset configuration ([75eb15b](https://github.com/anyproto/any-sync-dockercompose/commit/75eb15ba344cec35d14880a78bd14a961218989a) by Kirill Shklyaev).

## [v2.1.2](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v2.1.2) - 2024-02-19

<small>[Compare with v2.1.1](https://github.com/anyproto/any-sync-dockercompose/compare/v2.1.1...v2.1.2)</small>

### Added

- added automatic changelog generation ([e750942](https://github.com/anyproto/any-sync-dockercompose/commit/e7509426a08dba111f22cad8d7b39dd4a1faf01f) by Kirill Shklyaev).

### Fixed

- fixed replacement of variables in aws credentials file ([9c81b9f](https://github.com/anyproto/any-sync-dockercompose/commit/9c81b9f3c3f5e11ad4d3539e9a5c8a78425944a1) by Kirill Shklyaev).

## [v2.1.1](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v2.1.1) - 2024-02-14

<small>[Compare with v2.1.0](https://github.com/anyproto/any-sync-dockercompose/compare/v2.1.0...v2.1.1)</small>

## [v2.1.0](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v2.1.0) - 2024-02-14

<small>[Compare with v2.0.1](https://github.com/anyproto/any-sync-dockercompose/compare/v2.0.1...v2.1.0)</small>

### Added

- added docker-compose.any-sync-admin.yml fixed mongo url for any-sync-admin ([62618c0](https://github.com/anyproto/any-sync-dockercompose/commit/62618c074188ec1e462b03ab43e212e87540eb2c) by Grigory Efimov).
- added any-sync-admin ([93362b8](https://github.com/anyproto/any-sync-dockercompose/commit/93362b87eeefe2eca19ce5b2365b9940ea7bee11) by Grigory Efimov).

## [v2.0.1](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v2.0.1) - 2024-01-24

<small>[Compare with v1.0.4](https://github.com/anyproto/any-sync-dockercompose/compare/v1.0.4...v2.0.1)</small>

### Added

- Added warning about switching to new s3 backend ([383177a](https://github.com/anyproto/any-sync-dockercompose/commit/383177a7c5ac6289dcae50b3cb3b966e77b64022) by Kirill Shklyaev).
- Added new s3 backend: minio, added health checks for services ([0716d8b](https://github.com/anyproto/any-sync-dockercompose/commit/0716d8b60c2f6f5e94831b3a4c9230e0bb888c2b) by Kirill Shklyaev).
- Added information on how to use config file ([4c9ed0d](https://github.com/anyproto/any-sync-dockercompose/commit/4c9ed0d7644ccac482a0aed05a0c99b687356666) by Kirill Shklyaev).
- Added new variables for coordinator, filenode and minio s3 ([199be20](https://github.com/anyproto/any-sync-dockercompose/commit/199be204f5b4c33b52eb7b5d38244a993163fcf3) by Kirill Shklyaev).

## [v1.0.4](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v1.0.4) - 2024-01-15

<small>[Compare with v1.0.3](https://github.com/anyproto/any-sync-dockercompose/compare/v1.0.3...v1.0.4)</small>

### Added

- added EXTERNAL_LISTEN_HOST added fileLimit ([ea1ce33](https://github.com/anyproto/any-sync-dockercompose/commit/ea1ce33660ecc840b9509386069a4dfaada72eb1) by Grigory Efimov).

### Fixed

- fixed redis-servr data dir and fixed s3 emulator dns name ([ebf56e9](https://github.com/anyproto/any-sync-dockercompose/commit/ebf56e9190ef89d7abaa617bae862b082445cbe2) by Grigory Efimov).

## [v1.0.3](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v1.0.3) - 2024-01-15

<small>[Compare with v1.0.2](https://github.com/anyproto/any-sync-dockercompose/compare/v1.0.2...v1.0.3)</small>

### Fixed

- Fixed installation of yq-package in Dockerfile-generateconfig ([37aa8c8](https://github.com/anyproto/any-sync-dockercompose/commit/37aa8c8702b339b8ebf8e136a9a25e1cfa9899bf) by Kirill Shklyaev).

## [v1.0.2](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v1.0.2) - 2023-11-14

<small>[Compare with v1.0.1](https://github.com/anyproto/any-sync-dockercompose/compare/v1.0.1...v1.0.2)</small>

### Added

- added versions to env, fixed variable names in script, fixes in Makefile ([7e307b1](https://github.com/anyproto/any-sync-dockercompose/commit/7e307b1bd32421d874a378c0e1f72816ffb2ccdd) by Kirill Shklyaev).

## [v1.0.1](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v1.0.1) - 2023-10-25

<small>[Compare with v1.0.0](https://github.com/anyproto/any-sync-dockercompose/compare/v1.0.0...v1.0.1)</small>

## [v1.0.0](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v1.0.0) - 2023-10-02

<small>[Compare with v0.0.1](https://github.com/anyproto/any-sync-dockercompose/compare/v0.0.1...v1.0.0)</small>

### Added

- added quic support ([23e5db8](https://github.com/anyproto/any-sync-dockercompose/commit/23e5db8d0c0186645e67bdef930958196d2dfc05) by Grigory Efimov).

## [v0.0.1](https://github.com/anyproto/any-sync-dockercompose/releases/tag/v0.0.1) - 2023-09-14

<small>[Compare with first commit](https://github.com/anyproto/any-sync-dockercompose/compare/6a264d71210ff52aa7dc490b1c98d821844911f0...v0.0.1)</small>

### Added

- added .github/workflows/release.yml ([bca1da3](https://github.com/anyproto/any-sync-dockercompose/commit/bca1da3ac10d6795dadc825c99c55a795c71839c) by Grigory Efimov).
- added .github/workflows/ossf.yml ([a1dd97f](https://github.com/anyproto/any-sync-dockercompose/commit/a1dd97f88ad446fe179b10fa25719eb162b6a0e9) by Grigory Efimov).
- added anyconf for generate configs ([ea780d0](https://github.com/anyproto/any-sync-dockercompose/commit/ea780d0b74d5eb1aa222860f36066e932e772924) by Grigory Efimov).
- added .github/CODEOWNERS ([1f640b0](https://github.com/anyproto/any-sync-dockercompose/commit/1f640b01683c17ed56d3ced1a546724611ef19db) by Grigory Efimov).
- added consensusnode ([6598910](https://github.com/anyproto/any-sync-dockercompose/commit/65989100628f4b4ec33959fdec017c1fca03e699) by Grigory Efimov).
- added docker-compose.any-sync-tools.yml ([89a5608](https://github.com/anyproto/any-sync-dockercompose/commit/89a56087d17d8df5c8faaa156bbae3417cd4c38a) by Grigory Efimov).
- Add default space deleter running configuration ([ea17f9d](https://github.com/anyproto/any-sync-dockercompose/commit/ea17f9d39622f49b6d994ca114c1fbed23774a84) by Dmitry Bilienko).
- added generate_etc ([81dbabe](https://github.com/anyproto/any-sync-dockercompose/commit/81dbabe0c7489eeef31d133fb96c06cf3a32af80) by Kirill).
- add specific versions support ([a52d495](https://github.com/anyproto/any-sync-dockercompose/commit/a52d4956a2611ac5550ac3200af8c755c72bf158) by Kirill).
- add s3-emulator ([e47a252](https://github.com/anyproto/any-sync-dockercompose/commit/e47a25222714bf8a6cbc9f4a5350734a8438e4fb) by Kirill).
- add README.md ([0da0f00](https://github.com/anyproto/any-sync-dockercompose/commit/0da0f00224edf8299469a3052714fefb83c563c5) by Kirill).

### Fixed

- fixed generateconfig - remove ssh ([88eaaf2](https://github.com/anyproto/any-sync-dockercompose/commit/88eaaf2eb26e9cc5c1d3c146a028cf6a22b0f216) by Grigory Efimov).
- fixed yq ([4284b10](https://github.com/anyproto/any-sync-dockercompose/commit/4284b105f5fc67a687a44073f71de88546df1330) by Grigory Efimov).
- fixed README.md ([762a2c7](https://github.com/anyproto/any-sync-dockercompose/commit/762a2c703aa8d61d1f6c4521999ead5dc200665c) by Kirill).
- fixed docker-compose ([9c2bcef](https://github.com/anyproto/any-sync-dockercompose/commit/9c2bceffad57a3cdcc47f468d3f2acb67c2f4379) by Kirill).
- fixed Makefile add info in README.md ([c30fc21](https://github.com/anyproto/any-sync-dockercompose/commit/c30fc210f068950ee9d9d6e39f0697d613decc52) by Kirill).
- fixed Makefile ([bbf60b1](https://github.com/anyproto/any-sync-dockercompose/commit/bbf60b117f279de6073633d62f04a00b8715b093) by Kirill).

