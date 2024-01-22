# bitcoind-alpine
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://github.com/comminutus/bitcoind-alpine/actions/workflows/ci.yaml/badge.svg)](https://github.com/comminutus/bitcoind-alpine/actions/workflows/ci.yaml)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/comminutus/bitcoind-alpine)](https://github.com/comminutus/bitcoind-alpine/releases/latest)


## Description
`bitcoind-alpine` is a [Bitcoin Core](https://github.com/bitcoin/bitcoin) container image compiled for Alpine Linux.  The container image runs `bitcoind`.

## Getting Started
```
podman pull ghcr.io/comminutus/bitcoind-alpine
podman run -it --rm ghcr.io/comminutus/bitcoind-alpine
```

## Usage

### Environment Variables and Options
Because `bitcoind` supports so many options, it's best to configure it using a configuration file (typically _bitcoin.conf_). The `bitcoind` command line options can be used to point to the configuration file.
For a description of all of the various `bitcoind` configuration options, please see the example configuration file at _/home/bitcoind/.bitcoin/bitcoin.conf_.

**Supported Environment Variables:**
| Environment Variable | `bitcoind` Option | Default Value                          |
| -------------------- | ----------------- | -------------------------------------- |
| `BITCOIND_CONF`      | `-conf`           | _/home/bitcoind/.bitcoin/bitcoin.conf_ |
| `BITCOIND_DATA_DIR`  | `-$data_dir`      | _/var/lib/bitcoin_                     |

If there are other options you'd like to set that don't correspond to an environment variable, you can provide them by setting `BITCOIND_ADDITIONAL_ARGS` to include other arguments.  For example: `BITCOIND_ADDITIONAL_ARGS=-bitcoin -estimatefee -server -txindex`.

### Volumes
By default, the container's persistent data, including configuration and blockchain data are stored at _/var/lib/bitcoin_.
You can change this by setting the `BITCOIND_DATA_DIR` environment variable.

This can be useful if you're running the container image with Docker, Kubernetes, OpenShift, etc.  Mount your volumes at
_/var/lib/bitcoin_ or wherever you choose to set `BITCOIND_DATA_DIR` to.

_You should also mount your own configuration file_.  The default path is at _/home/bitcoind/.bitcoin/bitcoin.conf_.  **The existing configuration file in the image at this path is meant to be used as an example only.**

### User/Group
The container uses a user named _bitcoind_ with a UID of _10000_, with a group that matches the same.  If you'd like to change this, rebuild
the container and set the `uid` build argument.

### Ports
The container exposes the following ports:
| Port  | Use                                                                   |
| ----- | --------------------------------------------------------------------- |
| 8332  | JSON-RPC communication; for wallets, tools, etc.                      |
| 8333  | peer-to-peer communication; for node to communicate with other nodes  |
| 28332 | ZeroMQ port; for subscribing to specific events using a message queue |

## License
This project inherits Bitcoin Core's MIT license - see the [LICENSE](LICENSE) file for details.
