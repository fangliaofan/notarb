
# 🚀 NotArb Jupiter Server Configuration Guide

![GitHub release](https://img.shields.io/github/v/release/NotArb/Release)
![License](https://img.shields.io/badge/license-MIT-blue)

> **Complete technical reference for Jupiter Server configuration**  
> *Optimized for both Jito and Spam strategies*

---

## 📋 Table of Contents
1. [✨ Quick Start](#-quick-start)
2. [🔧 Core Configuration](#-core-configuration)  
   - [Launcher Settings](#launcher-settings)  
   - [Manager Settings](#manager-settings)
3. [🌍 Environment Variables](#-environment-variables)  
   - [Essential Variables](#essential-variables)  
   - [Advanced Variables](#advanced-variables)
4. [🪙 Mint Suppliers](#-mint-suppliers)
5. [📚 Complete Examples](#-complete-examples)  
   - [Jito-Optimized Server](#jito-optimized-server)  
   - [Spam-Optimized Server](#spam-optimized-server)

---

## ✨ Quick Start

```bash
# 1. Download and extract
wget https://github.com/NotArb/Release/releases/download/v1.0.0/notarb-1.0.0.zip
unzip notarb-1.0.0.zip -d notarb
cd notarb/jupiter-server
```

```bash
# 2. Configure server
cp example.toml myjupiter.toml
nano myjupiter.toml
```

```bash
# 3. Start the server
bash notarb.sh jupiter-server/myjupiter.toml
```

> Note: The Jupiter Server must be running before starting your bot instances.

---

## 🔧 Core Configuration

### Launcher Settings

```toml
[launcher]
task = "jupiter-server"  # Required identifier
jvm_args = [
    "-server",         # Server-optimized JVM mode
    "-Xmx4096m",       # Max memory allocation (4GB)
    "-XX:+UseSerialGC" # Garbage collector selection
]
```

| Field    | Type     | Description              |
|----------|----------|--------------------------|
| task     | string   | Must be "jupiter-server" |
| jvm_args | string[] | JVM optimization flags   |

---

### Manager Settings

```toml
[manager]
jupiter_path = ""  # Leave empty for auto-install
jupiter_release = "v6.0.47"  # Default version
startup_cmd = ["/bin/bash", "-c", "echo Pre-start command"]
auto_restart_minutes = 10  # 0 = disable
```

| Field                | Type     | Description                   |
|---------------------|----------|-------------------------------|
| jupiter_path        | string   | Custom Jupiter CLI path       |
| jupiter_release     | string   | Version to auto-install       |
| startup_cmd         | string[] | Commands to run pre-start     |
| auto_restart_minutes| int      | Scheduled restart interval    |

---

## 🌍 Environment Variables

### Essential Variables

```toml
[env]
HOST = "127.0.0.1"  # Binding address
PORT = "8080"       # Listening port
RPC_URL = "https://your.rpc.url"  # Your Solana RPC
RUST_LOG = "info"   # Log level (debug, info, warn, error)
RUST_BACKTRACE = "full"  # Error tracing
```
| Variable       | Description                          |
|----------------|--------------------------------------|
| HOST           | Application bind address             |
| PORT           | Listening port for HTTP server       |
| RPC_URL        | Solana RPC endpoint                  |
| RUST_LOG       | Log level: debug, info, warn, error  |
| RUST_BACKTRACE | Enables detailed error backtrace     |

---

### Advanced Variables

```toml
ALLOW_CIRCULAR_ARBITRAGE = "true"  # Enable arbitrage loops
MARKET_MODE = "remote"             # Market data source mode
ENABLE_NEW_DEXES = "true"          # Enable recently integrated DEXs
MARKET_CACHE = ""                  # Market cache override (file/url)
JUPITER_EUROPA_URL = ""            # Runtime market updater URL
YELLOWSTONE_GRPC_ENDPOINT = ""     # gRPC endpoint for Jito
YELLOWSTONE_GRPC_X_TOKEN = ""      # gRPC token for Jito
YELLOWSTONE_GRPC_ENABLE_PING = "true" # Ping gRPC server to maintain connection
SNAPSHOT_POLL_INTERVAL_MS = "30000"   # Poll interval for AMM accounts (in ms)
ENABLE_EXTERNAL_AMM_LOADING = "false" # Enable external AMM loading
DISABLE_SWAP_CACHE_LOADING = "false"  # Disable lookup tables and cache
DEX_PROGRAM_IDS = ""              # Restrict to specific DEX program IDs
FILTER_MARKETS_WITH_MINTS = ""    # Mint filtering for market inclusion
SENTRY_DSN = ""                   # Sentry error tracking DSN
EXPOSE_QUOTE_AND_SIMULATE = "false" # Expose quote & simulate endpoints
ENABLE_DEPRECATED_INDEXED_ROUTE_MAPS = "false" # Deprecated indexed maps
ENABLE_DIAGNOSTIC = "false"       # Enable diagnostic API endpoint
ENABLE_ADD_MARKET = "false"       # Enable hot-loading markets
METRICS_PORT = "9090"             # Port for Prometheus `/metrics`
```

| Variable                             | Description |
|--------------------------------------|-------------|
| ALLOW_CIRCULAR_ARBITRAGE             | Enable arbitrage loops where input equals output |
| MARKET_MODE                          | Choose between `europa`, `remote`, or `file` |
| ENABLE_NEW_DEXES                     | Auto-enable newly integrated DEXs |
| MARKET_CACHE                         | Override default market source with a URL or file |
| JUPITER_EUROPA_URL                   | Europa URL for dynamic market loading |
| YELLOWSTONE_GRPC_ENDPOINT            | gRPC endpoint for Jito/Yellowstone RPC |
| YELLOWSTONE_GRPC_X_TOKEN             | Token for Yellowstone gRPC |
| YELLOWSTONE_GRPC_ENABLE_PING         | Enable gRPC server pings |
| SNAPSHOT_POLL_INTERVAL_MS            | Snapshot polling interval in milliseconds |
| ENABLE_EXTERNAL_AMM_LOADING          | Enable support for external AMMs |
| DISABLE_SWAP_CACHE_LOADING           | Skip loading cache and lookup tables |
| DEX_PROGRAM_IDS                      | Only load specific DEX program IDs |
| FILTER_MARKETS_WITH_MINTS            | Filter markets to include only specific mint sets |
| SENTRY_DSN                           | Sentry integration for error tracking |
| EXPOSE_QUOTE_AND_SIMULATE            | Expose internal quote/simulation APIs |
| ENABLE_DEPRECATED_INDEXED_ROUTE_MAPS | Enable deprecated routing APIs |
| ENABLE_DIAGNOSTIC                    | Enable diagnostics endpoint |
| ENABLE_ADD_MARKET                    | Allow runtime addition of markets |
| METRICS_PORT                         | Port for exposing Prometheus metrics |

---

## 🪙 Mint Suppliers

```toml
[[file_mints]]
enabled = true
path = "mints.txt"  # Supports .txt or .json
```

| Field          | Description                         |
|----------------|-------------------------------------|
| enabled        | Enable/disable file mint loading    |
| path           | File path to mint list (.txt/.json) |


---

## 📚 Complete Examples

### Jito-Optimized Server

```toml
[launcher]
task = "jupiter-server"
jvm_args = ["-server", "-Xmx8192m", "-XX:+UseSerialGC"]

[manager]
jupiter_release = "v6.0.47"
auto_restart_minutes = 120

[env]
HOST = "127.0.0.1"
PORT = "8080"
RPC_URL = "https://jito-rpc.example.com"
RUST_LOG = "info"
ALLOW_CIRCULAR_ARBITRAGE = "true"
MARKET_MODE = "remote"
ENABLE_NEW_DEXES = "true"
YELLOWSTONE_GRPC_ENDPOINT = "https://jito-grpc.example.com"
YELLOWSTONE_GRPC_X_TOKEN = "your_jito_token"
YELLOWSTONE_GRPC_ENABLE_PING = "true"
SNAPSHOT_POLL_INTERVAL_MS = "30000"
METRICS_PORT = "9090"

[[file_mints]]
enabled = true
path = "/config/jito-mints.txt"
```

---

### Spam-Optimized Server

```toml
[launcher]
task = "jupiter-server"
jvm_args = ["-server", "-Xmx4096m", "-XX:+UseSerialGC"]

[manager]
jupiter_path = ""
auto_restart_minutes = 0

[env]
HOST = "127.0.0.1"
PORT = "8081"
RPC_URL = "https://spam-rpc.example.com"
RUST_LOG = "warn"
ALLOW_CIRCULAR_ARBITRAGE = "true"
MARKET_MODE = "local"
ENABLE_NEW_DEXES = "false"
YELLOWSTONE_GRPC_ENDPOINT = "https://jito-grpc.example.com"
YELLOWSTONE_GRPC_X_TOKEN = "your_jito_token"
YELLOWSTONE_GRPC_ENABLE_PING = "true"

[[file_mints]]
enabled = true
path = "/config/spam-mints.txt"
```

---
