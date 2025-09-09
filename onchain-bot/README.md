
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
   - [🧠 Strategy Variables](#-strategy-variables)
   - [🧠 Jito Variables](#-jito-variables)
   - [🌀 Spam Variables](#-spam-variables)
   - [📊 Supported DEXes](#-supported-dexes)
   - [➕ Fast & Astralane Low-Tip Senders](#-fast--astralane-low-tip-senders)
3. [🔧 Essential Services](#essential-services)
4. [🌀 Dynamic Strategy Attributes](#-dynamic-strategy-attributes)
5. [🔄 Market Configuration](#-market-configuration)
   - [File-based Markets](#file-based-markets)
   - [URL-based Markets](#url-based-markets)
6. [🔍 Lookup Tables](#-lookup-tables)
   - [File-based](#file-based)
   - [URL-based](#url-based)
7. [📦 Account Size Loader](#-account-size-loader)
8. [🔄 WSOL Unwrapper](#-wsol-unwrapper)
9. [⚡ Transaction Execution](#-transaction-execution)
10. [📚 Complete Examples](#-complete-examples)
    - [✅ Jito Configuration](#-jito-configuration)
    - [✅ Spam Configuration](#-spam-configuration)
    - [✅ Jito + Spam Full Example](#-jito--spam-full-example)
11. [🔗 Official Links](#-official-links)
---



## ✨ Quick Start

### For Linux/Mac

1. **Download and extract**  
   Go to the [latest release page](https://github.com/NotArb/Release/releases/latest) and download the `.zip` file. Then extract and navigate to the bot directory:

   ```bash
   unzip notarb-x.x.x.zip -d notarb
   cd notarb/onchain-bot
   ```

2. **Configure your bot**

   ```bash
   cp example.toml myconfig.toml
   nano myconfig.toml
   ```

3. **Start the bot**

   ```bash
   bash notarb.sh myconfig.toml
   ```

### For Windows

1. **Download and extract**  
   Go to the [latest release page](https://github.com/NotArb/Release/releases/latest) and download the `.zip` file. Then extract the archive using File Explorer or any zip utility.

2. **Configure your bot**

   ```cmd
   cd onchain-bot
   copy example.toml myconfig.toml
   notepad myconfig.toml
   ```

3. **Start the bot**

   ```cmd
   .\notarb.bat myconfig.toml
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

These apply to chain state validation and timing.

| Field              | Type   | Description                                                                 |
|--------------------|--------|-----------------------------------------------------------------------------|
| `update_timestamp` | int    | Unix timestamp in milliseconds. Market configs older than 5 minutes are ignored. |

---

### 🧠 Strategy Variables

These are the core strategy-level configuration options used across spam and Jito execution paths.

| Field                        | Type   | Description                                                                 |
|------------------------------|--------|-----------------------------------------------------------------------------|
| `meteora_bin_limit`          | int    | Max number of bins for Meteora swaps (recommendation: 20).                  |
| `cu_limit`                   | int    | Compute unit cap per transaction.                                           |
| `flash_loan`                 | bool   | Enables flash loan functionality (12.5% fee on profits only). Regular trades: 10% fee. The bot will randomly choose 1/2 available vaults. Default: false |
| `max_lookup_tables`          | int    | Maximum number of address lookup tables to use per route (default: 10).     |
| `require_profit`             | bool   | When false, executes all swaps with Jito (always tips). When true (default), only executes profitable swaps after fees. |
| `min_priority_fee_lamports`  | int    | Minimum priority fee (in lamports) for spam transactions.                   |
| `max_priority_fee_lamports`  | int    | Maximum priority fee (in lamports) for spam transactions.                   |

---

### 🧠 Jito Variables

| Field                      | Type   | Description                                                                 |
|----------------------------|--------|-----------------------------------------------------------------------------|
| `min_jito_tip_lamports`    | int    | Minimum Jito tip in lamports per transaction.                               |
| `max_jito_tip_lamports`    | int    | Maximum Jito tip in lamports per transaction.                               |
| `exclude_jito_senders`     | array  | List of `jito.rpc` or `jito.rpc_proxy` IDs to exclude from sending.         |
| `include_jito_senders`     | array  | List of `jito.rpc` or `jito.rpc_proxy` IDs to include.                      |
| `max_bundle_transactions`  | int    | Max transactions to bundle together per Jito sender. Applies only when `min_profit_lamports = 0`. |

---

### 🌀 Spam Variables

| Field                  | Type     | Description                                                       |
|------------------------|----------|-------------------------------------------------------------------|
| `cooldown_ms`          | int      | Milliseconds to wait between each transaction attempt.            |
| `max_idle_connections` | int      | Maximum number of persistent HTTP connections per spam RPC.       |
| `spam_senders`         | array    | List of RPC endpoint configurations used to spam transactions.    |

#### 🔁 `spam_senders` Item Structure

Each entry in the `spam_senders` array should be an object with the following fields:

| Field                   | Type     | Description                                                                 |
|-------------------------|----------|-----------------------------------------------------------------------------|
| `url`                   | string   | RPC endpoint URL.                                                           |
| `preflight_commitment` | string   | Commitment level for preflight checks. Options:<br>`"processed"`<br>`"confirmed"`<br>`"finalized"` |
| `max_retries`           | int      | Maximum number of retry attempts for the transaction. If not set, it will retry until the blockhash expires or the transaction lands. Typically set to `0`. |

---

## 🔗 Supported DEXes

> ℹ️ **Note:** You can add any unsupported market to your configuration.  
> The bot will automatically filter out unsupported entries—they will not cause an error.

| DEX Name         | Address                                      |
|------------------|----------------------------------------------|
| `Raydium AMM`    | `675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8` |
| `Raydium CPMM`       | `CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C` |
| `Raydium CLMM`       | `CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK` |
| `Meteora DLMM`   | `LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo` |
| `Meteora DAMMV2` | `cpamdpZCGKUy5JxQXB4dcpGPiikHawvSWAd6mEn1sGG` |
| `Pump.Fun AMM`       | `pAMMBay6oceH9fJKBRHGP5D4bD4sWpmSwMn52FMfXEA` |
| `Whirlpool`      | `whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc` |
| `GOOSEFX (GAMMA)`      | `GAMMA7meSFWaBXF25oSUgmGRwaW6sCMFLmBNiMSdbHVT` |
---

---

### ➕ Fast & Astralane Low-Tip Senders

#### 🚀 Fast (Circular)

Minimum **7500 lamport tip** required.

```toml
[[spam_rpc]]
id = "circular-fast"
url = "https://fast.circular.fi/transactions/no-failure/notarb"
max_idle_connections = 1
tip_meta = { type = "FAST", api_key = "${CIRCULAR_API_KEY}" }
```

> ⚠️ This endpoint **will not work** when using `require_profit = true`.

---

#### 🌌 Astralane

Minimum **10,000 lamport tip** required.

```toml
[[spam_rpc]]
id = "astra-ny"
url = "https://ny.gateway.astralane.io/iris"
max_idle_connections = 1
tip_meta = { type = "ASTRALANE", api_key = "${ASTRALANE_API_KEY}" }
```

---

### ⚙️ Tip Configuration in Strategies

Tips are configured in strategy settings using `min_spam_tip_lamports` and `max_spam_tip_lamports`:

```toml
[[swap]]
enabled = true
mint = "SOL"

[swap.strategy_defaults]
meteora_bin_limit = 12 # default 20 — helps reduce CU usage on high liquidity markets

spam_senders = [
    { rpc = "astra-ny" }
]

[[swap.strategy]]
cu_limit = 369_369
min_priority_fee_lamports = { key = "min_prio_fee", default_value = 190 }
max_priority_fee_lamports = { key = "max_prio_fee", default_value = 19000 }
min_spam_tip_lamports = 10_000 
max_spam_tip_lamports = 10_000
cooldown_ms = 250
```
---

## Essential Services

```toml
[token_accounts_checker]
rpc_url="${DEFAULT_RPC_URL}"
delay_seconds=3

[blockhash_updater]
rpc_url="${DEFAULT_RPC_URL}"
delay_ms=1000

[market_loader]
rpc_url="${DEFAULT_RPC_URL}"

[lookup_table_loader]
rpc_url="${DEFAULT_RPC_URL}"
```
---
## 🌀 Dynamic Strategy Attributes

> 🚀 Dynamically update strategy parameters without restarting the bot.  
> Enables real-time strategy adjustments through external configuration files.

### Configuration
```toml
[dynamic_attributes]
path="/path/to/attributes-file.json"
update_ms=50
```

### Supported Fields
| Field | Type | Description |
|-------|------|-------------|
| `enabled` | bool | Enable/disable strategy |
| `cu_limit` | int | Compute unit limit |
| `min_priority_fee_lamports` | int | Min priority fee |
| `max_priority_fee_lamports` | int | Max priority fee |
| `min_jito_tip_lamports` | int | Min Jito tip |
| `max_jito_tip_lamports` | int | Max Jito tip |
| `cooldown_ms` | int | Transaction delay |

### Example
**Attributes File:**
```json
{
  "enable_strat": true,
  "strat_cu": 400000,
  "min_prio": 50000,
  "cooldown": 50
}
```

**Strategy Config:**
```toml
[[swap.strategy]]
enabled={key="enable_strat",default_value=false}
cu_limit={key="strat_cu",default_value=300000}
min_priority_fee_lamports={key="min_prio",default_value=0}
cooldown_ms={key="cooldown",default_value=1000}
```
---
## 📦 Account Size Loader

> ⚠️ **Optional:** The Account Size Loader is used to optimize transaction priority by accurately estimating the memory allocation for Solana accounts.  
> By default, Solana allocates 64MB of memory for accounts, but this can be significantly reduced to gain better priority in transactions.

| Variable             | Type | Description                                                                                          |
|----------------------|------|------------------------------------------------------------------------------------------------------|
| `rpc_url`            | string | RPC endpoint used to fetch account sizes.                                                         |
| `invalid_account_size`| int  | Default size (in bytes) to use for accounts that do not exist or return no data.                     |
| `buffer_size`        | int  | Extra bytes to add as a safety margin when calculating account sizes (can be set to 0).              |

```toml
[account_size_loader]
rpc_url="${DEFAULT_RPC_URL}"
invalid_account_size=100       # Default size for invalid accounts
buffer_size=1000               # Additional buffer bytes added to account size
```
---
## 🔄 WSOL Unwrapper

> ⚠️ **Optional:** Automatically unwraps WSOL when your SOL balance falls below a specified threshold.  

### Configuration Parameters

| Variable               | Type     | Description                                                                                          |
|------------------------|----------|------------------------------------------------------------------------------------------------------|
| `enabled`              | bool     | Must be `true` to activate automatic unwrapping (default: `false`)                                   |
| `check_minutes`        | int      | Frequency in minutes to check balance (minimum: 1, default: 5)                                      |
| `trigger_sol`          | float    | Triggers unwrap when SOL balance falls below this amount (default: 0.5)                             |
| `target_sol`          | float    | Target SOL balance to maintain after unwrapping (default: 1.0)                                      |
| `priority_fee_lamports`| int      | Optional priority fee to help transactions land (recommended: 190-500, default: 0)                  |
| `reader_rpc_url`       | string   | RPC used for balance checks (low-latency recommended)                                               |
| `sender_rpc_urls`      | string[] | List of RPCs for sending unwrap transactions (at least 1 required)                                  |

### Example Configuration

```toml
[wsol_unwrapper]
enabled=true
check_minutes=1            # Check balance every minute
trigger_sol=0.5           # Unwrap when SOL < 0.5
target_sol=1.0            # Maintain at least 1 SOL unwrapped
priority_fee_lamports=190  # Priority fee for unwrap txs
reader_rpc_url="http://ny-rpc.notarb.org:7399/"
sender_rpc_urls=[
    "http://ny-rpc.notarb.org:7399/",
    "http://ny-rpc2.notarb.org:7400/"
]
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
delay_ms=1000

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
require_profit=false

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
delay_ms=1000

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
  { rpc="primary-rpc", preflight_commitment="confirmed", max_retries=0 },
  { rpc="jito-backup", preflight_commitment="confirmed", max_retries=0 }
]
```

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
delay_ms=1000

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
cooldown_ms=1337
#exclude_jito_senders=["jito-2"] # optionally exclude specific jito senders
require_profit=false

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
    { rpc="my-super-duper-sender", preflight_commitment="confirmed", max_retries=0 },
]
cooldown_ms=369
```
---

> ⚠️ Always download from official sources. Never accept programs or scripts from other users.

## 🔗 Official Links

- 📦 [Download NotArb](https://github.com/NotArb/Release/releases/)
- 📊 [Dune On-Chain Dashboard](https://dune.com/notarb/notarb-on-chain-dashboard)
- 💬 [Join Discord](https://discord.notarb.org)
