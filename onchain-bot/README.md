
# 🚀 NotArb On-Chain Bot Configuration Guide

![GitHub release](https://img.shields.io/github/v/release/NotArb/Release)

[![Join Discord](https://dcbadge.limes.pink/api/server/mYfAQnBfqy)](https://discord.notarb.org)

> **Complete technical reference guide for the NotArb On-Chain Bot**  
> *Exact specifications each parameters with examples for both Jito and Spam*

---

## 📋 Table of Contents

1. [✨ Quick Start](#-quick-start)
   - [For Linux/Mac](#for-linuxmac)
   - [For Windows](#for-windows)
2. [⚙️ Core Configuration](#️-core-configuration)
   - [🔗 On-Chain Specific Variables](#-on-chain-specific-variables)
   - [🧠 Jito](#-jito-variables)
   - [🌀 Spam](#-spam-variables)
   - [📊 Supported DEXes](#-supported-dexes)
3. [🔧 Essential Services](#essential-services)
4. [🔄 Market Configuration](#-market-configuration)
   - [File-based Markets](#file-based-markets)
   - [URL-based Markets](#url-based-markets)
5. [🔍 Lookup Tables](#-lookup-tables)
   - [File-based](#file-based)
   - [URL-based](#url-based)
6. [⚡ Transaction Execution](#-transaction-execution)
7. [🎯 Strategy Configuration](#-strategy-configuration)
   - [🧠 Jito Mode](#-jito-mode)
   - [🌀 Spam Mode](#-spam-mode)
8. [📚 Complete Examples](#-complete-examples)
   - [✅ Jito Configuration](#-jito-configuration)
   - [✅ Spam Configuration](#-spam-configuration)
   - [✅ Jito + Spam Full Example](#-jito--spam-full-example)
9. [🔗 Official Links](#-official-links)

---

## ✨ Quick Start

### For Linux/Mac

```bash
# 1. Download and extract
wget https://github.com/NotArb/Release/releases/download/v1.0.0/notarb-1.0.0.zip
unzip notarb-1.0.0.zip -d notarb
cd notarb/onchain-bot

# 2. Configure your bot
cp example.toml myconfig.toml
nano myconfig.toml

# 3. Start the bot
bash notarb.sh myconfig.toml
```

### For Windows

```cmd
:: 1. Download and extract from:
:: https://github.com/NotArb/Release/releases/

:: 2. Configure your bot
cd onchain-bot
copy example.toml myconfig.toml
notepad myconfig.toml

:: 3. Start the bot
notarb.bat myconfig.toml
```

---

## ⚙️ Core Configuration

### `[launcher]`

| Field     | Type      | Description                      |
|-----------|-----------|----------------------------------|
| `task`      | string    | Must be `"onchain-bot"`          |
| `jvm_args`  | string[]  | JVM arguments for optimization   |

```toml
[launcher]
task="onchain-bot"
jvm_args=[
  "-server",
  "-Xmx8192m"
]
```

### `[notarb]`

| Field                         | Type  | Description                 |
|------------------------------|-------|-----------------------------|
| `acknowledge_terms_of_service` | bool  | Must be `true` to run       |

```toml
[notarb]
acknowledge_terms_of_service=true
```

### `[user]`

| Field         | Type    | Description                                  |
|---------------|---------|----------------------------------------------|
| `keypair_path`  | string  | Path to wallet keypair                       |
| `protect_keypair` | bool | Extra security for keypair                   |

```toml
[user]
keypair_path="${DEFAULT_KEYPAIR_PATH}"
protect_keypair=true
```

### 🔗 On-Chain Specific Variables

| Field               | Type   | Description                                                                 |
|---------------------|--------|-----------------------------------------------------------------------------|
| `meteora_bin_limit` | int    | Max number of bins for Meteora swaps (recommendation: 20)                   |
| `prefer_success`    | bool   | When `true` with Jito, ensures swaps succeed unless it results in fewer arb tokens |
| `cu_limit`          | int    | Compute unit cap per transaction.                                           |

### 🧠 Jito Variables

| Field                    | Type   | Description                                                                 |
|--------------------------|--------|-----------------------------------------------------------------------------|
| `min_jito_tip_lamports`  | int    | Minimum Jito tip in lamports per transaction.                               |
| `max_jito_tip_lamports`  | int    | Maximum Jito tip in lamports per transaction.                               |
| `exclude_jito_senders`   | array   | List of `jito.rpc_proxy` or `jito.rpc` `id`s to exclude from sending       |


### 🌀 Spam Variables

| Field                          | Type     | Description                                                                 |
|--------------------------------|----------|-----------------------------------------------------------------------------|
| `cu_limit`                     | int      | Compute unit cap per transaction.                                           |
| `min_priority_fee_lamports`    | int      | Minimum priority fee (in lamports) for spam transactions.                   |
| `max_priority_fee_lamports`    | int      | Maximum priority fee (in lamports) for spam transactions.                   |
| `cooldown_ms`                  | int      | Milliseconds to wait between each transaction attempt.                      |
| `spam_senders`                 | array    | List of RPC endpoints used to spam transactions.                            |
| `max_idle_connections`         | int      | Maximum number of persistent HTTP connections per spam RPC.                 |

## 🔗 Supported DEXes

> ℹ️ **Note:** You can add any unsupported market to your configuration.  
> The bot will automatically filter out unsupported entries—they will not cause an error.

| DEX Name     | Type     | Address                                      |
|--------------|----------|----------------------------------------------|
| Raydium AMM  | AMM      | `675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8` |
| Meteora DLMM | DLMM     | `LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo` |
| Pump AMM     | AMM      | `pAMMBay6oceH9fJKBRHGP5D4bD4sWpmSwMn52FMfXEA` |
| Ray CPMM     | CPMM     | `CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C` |

---

## Essential Services

```toml
[token_accounts_checker]
rpc_url="${DEFAULT_RPC_URL}"
delay_seconds=3

[blockhash_updater]
rpc_url="${DEFAULT_RPC_URL}"
delay_seconds=3

[market_loader]
rpc_url="${DEFAULT_RPC_URL}"

[lookup_table_loader]
rpc_url="${DEFAULT_RPC_URL}"
```

---

## 🔄 Market Configuration

### File-based Markets

```toml
[[markets_file]]
enabled=true
path="markets.toml" # also supports json, but must be a 2d array of market addresses
update_seconds=3
```

### URL-based Markets

```toml
[[markets_url]]
enabled=true
url="https://api.example.com/markets.toml" # also supports json, but must be a 2d array of market addresses
update_seconds=3
```

---

## 🔍 Lookup Tables

### File-based

```toml
[[lookup_tables_file]]
enabled=true
path="lookup-tables.txt"
update_seconds=3
```

### URL-based

```toml
[[lookup_tables_url]]
enabled=true
url="https://api.example.com/lookup-tables.txt"
update_seconds=3
```

---

## ⚡ Transaction Execution

```toml
[transaction_executor]
threads=0 
```

- `0`: dynamic pool (recommended)
- `-1`: unbounded (thread per task)
- `>0`: fixed-size pool

---

## 🎯 Strategy Configuration

### 🧠 Jito Mode

```toml
[jito]
ips_file_path="ips.txt"
prefunded_keypairs_path="keypairs.txt"

### UUID ###
[[jito.rpc]]
enabled=true
id="jito-1"
uuid="your-uuid-here"
regions=["ny", "slc", "london"]

### NON-UUID ###
[[jito.rpc]]
enabled=true
id="jito-1"
uuid="" #leave uuid empty or comment out this line
regions=["ny", "slc", "london"]

### BIND IPs ###
[[jito.rpc_proxy]] # Uses ips_file_path
enabled=true
id="jito-2"
regions=["ny", "slc", "london"]

[[swap]]
enabled=true
mint="SOL"

[swap.strategy_defaults]
meteora_bin_limit=20
prefer_success=false # warning: setting this to true will land txs and pay Jito tips even if there's no arbitrage opportunity.

[[swap.strategy]]
cu_limit=360000
min_jito_tip_lamports=1001   # Minimum tip in lamports to Jito validators
max_jito_tip_lamports=1111   # Maximum tip in lamports to Jito validators
cooldown_ms=1000
```

---

### 🌀 Spam Mode

```toml
[[spam_rpc]]
id="primary-rpc"
url="https://your.rpc.url"
max_idle_connections=1       # Max persistent connections to this RPC

[[spam_rpc]]
id="jito-spam-1"
url="https://ny.mainnet.block-engine.jito.wtf/api/v1/transactions"
max_idle_connections=1

[swap.strategy_defaults]
meteora_bin_limit=20

[[swap.strategy]]
cu_limit=369369                              # Compute units per transaction
min_priority_fee_lamports=10000              # Minimum priority fee
max_priority_fee_lamports=150000             # Maximum priority fee
cooldown_ms=1000                             # Milliseconds to wait before sending the next tx
spam_senders=[
  { rpc="primary-rpc", skip_preflight=true, max_retries=0 },
  { rpc="jito-spam-1", skip_preflight=true, max_retries=0 }
]
```

---

## 📚 Complete Examples

### ✅ Jito Configuration

```toml
[launcher]
task="onchain-bot"
jvm_args=["-server", "-Xmx8192m"]

[notarb]
acknowledge_terms_of_service=true

[user]
keypair_path="/path/to/keypair.json"
protect_keypair=true

[token_accounts_checker]
rpc_url="${DEFAULT_RPC_URL}"
delay_seconds=3

[blockhash_updater]
rpc_url="${DEFAULT_RPC_URL}"
delay_seconds=3

[market_loader]
rpc_url="${DEFAULT_RPC_URL}"

[lookup_table_loader]
rpc_url="${DEFAULT_RPC_URL}"

[transaction_executor]
threads=0

[[markets_file]]
enabled=true
path="markets.json"
update_seconds=3

[[lookup_tables_file]]
enabled=true
path="lookup-tables.txt"
update_seconds=3

[jito]
ips_file_path="ips.txt"
prefunded_keypairs_path="keypairs.txt"

[[jito.rpc]]
enabled=true
id="jito-1"
uuid="your-uuid-here"
regions=["ny", "slc", "london"]

[[swap]]
enabled=true
mint="SOL"

[swap.strategy_defaults]
meteora_bin_limit=20
prefer_success=true

[[swap.strategy]]
cu_limit=360000
min_jito_tip_lamports=1001
max_jito_tip_lamports=1111
cooldown_ms=1000
#exclude_jito_senders=["jito-2"] # optionally exclude specific jito senders
```

---

### ✅ Spam Configuration

```toml
[launcher]
task="onchain-bot"
jvm_args=["-server", "-Xmx8192m"]

[notarb]
acknowledge_terms_of_service=true

[user]
keypair_path="/path/to/keypair.json"
protect_keypair=true

[token_accounts_checker]
rpc_url="https://your.rpc.url"
delay_seconds=3

[blockhash_updater]
rpc_url="https://your.rpc.url"
delay_seconds=3

[market_loader]
rpc_url="https://your.rpc.url"

[lookup_table_loader]
rpc_url="https://your.rpc.url"

[transaction_executor]
threads=0

[[spam_rpc]]
id="primary-rpc"
url="https://your.rpc.url"
max_idle_connections=1

[[spam_rpc]]
id="jito-backup"
url="https://ny.mainnet.block-engine.jito.wtf/api/v1/transactions"
max_idle_connections=1

[[markets_file]]
enabled=true
path="markets.json"
update_seconds=3

[[lookup_tables_file]]
enabled=true
path="lookup-tables.txt"
update_seconds=3

[[swap]]
enabled=true
mint="SOL"

[swap.strategy_defaults]
meteora_bin_limit=20

[[swap.strategy]]
cu_limit=369369
min_priority_fee_lamports=10000
max_priority_fee_lamports=150000
cooldown_ms=1000
spam_senders=[
  { rpc="primary-rpc", skip_preflight=true, max_retries=0 },
  { rpc="jito-backup", skip_preflight=true, max_retries=0 }
]
```

---
---

### ✅ Jito + Spam Full Example

```toml

[launcher]
task="onchain-bot"
jvm_args=[
    "-server",
    "-Xmx4096m"
]

[notarb]
acknowledge_terms_of_service=false

[user]
keypair_path="${DEFAULT_KEYPAIR_PATH}"
protect_keypair=false

[token_accounts_checker]
rpc_url="${DEFAULT_RPC_URL}"
delay_seconds=3

[blockhash_updater]
rpc_url="${DEFAULT_RPC_URL}"
delay_seconds=3

[market_loader]
rpc_url="${DEFAULT_RPC_URL}"

[lookup_table_loader]
rpc_url="${DEFAULT_RPC_URL}"

[transaction_executor]
threads=4 # 0 will use a dynamic cached thread pool, -1 will use a thread per task, anything > 0 will use a fixed thread pool

[[spam_rpc]]
id="my-super-duper-sender"
url="${DEFAULT_RPC_URL}"
max_idle_connections=1

[jito]
ips_file_path="" # required for proxy senders (.txt file with 1 ip/proxy per line)
prefunded_keypairs_path="" # optional - only for proxy senders (.txt file with 1 keypair per line)

[[jito.rpc]]
enabled=true
id="jito-1"
uuid="" # leave empty if you have none - use cautiously, sends are not automatically rate limited like the jupiter bot
regions=["ny", "slc", "london", "frankfurt", "amsterdam", "tokyo"] # each region will be sent to concurrently

[[jito.rpc_proxy]]
enabled=false
id="jito-2"
regions=["ny", "slc", "london", "frankfurt", "amsterdam", "tokyo"]

[[markets_file]]
enabled=true
path="markets.toml" # also supports json, but must be a 2d array of market addresses
update_seconds=3

[[markets_url]]
enabled=false
url="https://notarb.org/markets.json" # also supports json, but must be a 2d array of market addresses
update_seconds=3

[[lookup_tables_file]]
enabled=true
path="lookup-tables.txt" # also supports json, but must be 1d array of market addresses
update_seconds=3

[[lookup_tables_url]]
enabled=false
path="https://notarb.org/lups.json" # also supports json, but must be 1d array of market addresses
update_seconds=3

## SOL (Jito)
[[swap]]
enabled=true
mint="SOL"

[swap.strategy_defaults]
meteora_bin_limit=20 # default 20 - helps keep cu down on high liquidity markets

[[swap.strategy]]
cu_limit=369_369
min_jito_tip_lamports=1000
max_jito_tip_lamports=1000
prefer_success=false # warning: setting this to true will land txs and pay Jito tips even if there's no arbitrage opportunity.
cooldown_ms=1337
#exclude_jito_senders=["jito-2"] # optionally exclude specific jito senders

## SOL (Spam)
[[swap]]
enabled=true
mint="SOL"

[swap.strategy_defaults]
meteora_bin_limit=20 # default 20 - helps keep cu down on high liquidity markets

[[swap.strategy]]
cu_limit=369_369
min_priority_fee_lamports=1900
max_priority_fee_lamports=6900
spam_senders=[
    { rpc="my-super-duper-sender", skip_preflight=true, max_retries=0 },
]
cooldown_ms=369
```
---

> ⚠️ Always download from official sources. Never accept programs or scripts from other users.

## 🔗 Official Links

- 📦 [Download NotArb](https://github.com/NotArb/Release/releases/)
- 📊 [Dune On-Chain Dashboard](https://dune.com/notarb/notarb-on-chain-dashboard)
- 💬 [Join Discord](https://discord.notarb.org)

