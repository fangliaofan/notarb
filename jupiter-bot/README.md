# 🚀 NotArb Jupiter Bot Configuration Guide

![GitHub release](https://img.shields.io/github/v/release/NotArb/Release)

[![Join Discord](https://dcbadge.limes.pink/api/server/mYfAQnBfqy)](https://discord.notarb.org)

> **Complete technical reference for NotArb Jupiter Bot configuration**  
> *Includes all fields with exact specifications and examples*

---

## 📋 Table of Contents
1. [✨ Quick Start](#-quick-start)
   - [For Linux/Mac](#for-linuxmac)
   - [For Windows](#for-windows)
2. [🔧 Core Configuration](#-core-configuration)
   - [Essential Services](#essential-services)
   - [Include Paths](#include_paths)
3. [🪙 Mint Suppliers](#-mint-suppliers)
   - [Mint Tags](#mint-tags)
   - [Timestamp in URLs](#timestamp-in-urls)
4. [🎯 Strategy Fields](#-strategy-fields)
   - [1.0 Quote Affecting Fields](#10-quote-affecting-fields)
   - [1.1 Entry Specific](#11-entry-specific)
   - [1.2 Exit Specific](#12-exit-specific)
   - [2.0 Transaction Skipping](#20-transaction-skipping)
   - [2.1 Gain Requirements](#21-gain-requirements)
   - [2.2 Error Printing](#22-error-printing)
   - [3.0 Transaction Building](#30-transaction-building)
   - [4.0 Jito Specific](#40-jito-specific)
     - [4.1 Tipping Configuration](#41-tipping-configuration)
     - [4.2 Connection Configuration](#42-connection-configuration)
   - [5.0 Spam Specific](#50-spam-specific)
   - [6.0 Kamino Flash Loans](#60-kamino-flash-loans)
5. [📚 Complete Examples](#-complete-examples)
   - [Jito Configuration](#jito-configuration)
   - [Spam Configuration](#spam-configuration)
   - [Kamino Flash Loans](#kamino-flash-loans)

---

## ✨ Quick Start

### For Linux/Mac

```bash
# 1. Download and extract
wget https://github.com/NotArb/Release/releases/download/v1.0.0/notarb-1.0.0.zip
unzip notarb-1.0.0.zip -d notarb
cd notarb

# 2. Configure global settings
nano notarb-global.toml

# 3. Set up Jupiter Server
cd jupiter-server
cp example.toml myjupiter.toml
nano myjupiter.toml

# 4. Start Jupiter Server (in first terminal)
bash notarb.sh jupiter-server/myjupiter.toml

# 5. Set up Bot (in second terminal)
cd jupiter-bot
cp example-jito.toml myjito.toml
# OR for Spam mode:
cp example-spam.toml myspam.toml

# 6. Start the Bot
bash notarb.sh jupiter-bot/myjito.toml
# OR for Spam mode:
bash notarb.sh jupiter-bot/myspam.toml
```

### For Windows

```cmd
:: 1. Download and extract from:
:: https://github.com/NotArb/Release/releases/

:: 2. Configure global settings
notepad notarb-global.toml

:: 3. Set up Jupiter Server
cd jupiter-server
copy example.toml myjupiter.toml
notepad myjupiter.toml

:: 4. Start Jupiter Server (in first Command Prompt)
notarb.bat jupiter-server\myjupiter.toml

:: 5. Set up Bot (in second Command Prompt)
cd jupiter-bot
copy example-jito.toml myjito.toml
:: OR for Spam mode:
copy example-spam.toml myspam.toml

:: 6. Start the Bot
notarb.bat jupiter-bot\myjito.toml
:: OR for Spam mode:
notarb.bat jupiter-bot\myspam.toml
```

> **Note**:  
> - Start Jupiter Server first, then the Bot  

---

## 🔧 Core Configuration

```toml
[bot_misc]
keypair_path = "${DEFAULT_KEYPAIR_PATH}"  # Uses path from notarb-global.toml
protect_keypair = true                 # Recommended
acknowledge_terms_of_service = false   # Must set true

[jupiter]
url = "http://localhost:8080" 
workers = 6
connect_timeout_ms = 5000
request_timeout_ms = 5000
```

### Essential Services

#### [blockhash_fetcher]
**Purpose**: Fetches recent blockhashes required for transaction processing
**Recommendation**: Use "${DEFAULT_RPC_URL}" to use DEFAULT_RPC_URL from notarb-global.toml

```toml
[blockhash_fetcher]
rpc_url = "${DEFAULT_RPC_URL}"  # Replace with your RPC endpoint
```

#### [token_accounts_fetcher]
**Purpose**: Checks which token accounts your wallet already has open  
**Why it's needed**: Speeds up transaction building by avoiding redundant account checks  
**Recommendation**: Use "${DEFAULT_RPC_URL}" to use DEFAULT_RPC_URL from notarb-global.toml

```toml
[token_accounts_fetcher]
rpc_url = "${DEFAULT_RPC_URL}"
```

#### [price_fetcher]
**Purpose**: Fetches token prices for accurate profit calculations  
**When**: Only required when using non-WSOL base tokens  

```toml
[price_fetcher]
#bind_ip = ""           # Optional: Bind to specific IP
#proxy_host = ""         # Optional: Proxy host
#proxy_port = 123        # Optional: Proxy port
#proxy_user = ""         # Optional: Proxy username
#proxy_pass = ""         # Optional: Proxy password
```

#### [plugin]
**Use DefaultJito for jito configurations and DefaultSpam for spam configurations**
```toml
[plugin]
class = "org.notarb.DefaultJito"  # or "org.notarb.DefaultSpam"
```
### include_paths

**Purpose**: Use this to modularize your configuration by easily including other TOML files.

```toml
include_paths = [
  "strategies/meme.toml",
  "strategies/stable.toml",
  "strategies/kamino.toml"
]
```

These paths are relative to the working directory where you run `notarb.sh` / `notarb.bat`.
Each file you include should be a valid TOML config file, typically containing sections like:

```toml
[[swap]]
enabled=true
mint="USDC"

[[swap.strategy]]
min_spend=1
max_spend=5000
min_gain_lamports=10000
priority_fee_percent=1
static_tip_percent=25
```
---

## 🪙 Mint Suppliers

### File-based Mints
```toml
[[file_mints]]
enabled = true
path = "/path/to/mints.txt"  # Supports both .txt and .json formats
update_seconds = 30          # Optional: How often to reload the file (0=never)
max_per_cycle = 20           # Optional: Limit mints processed per cycle
random_order = true          # Optional: Randomize processing order
```

### URL-based Mints
```toml
[[url_mints]]
enabled = true
url = "https://api.example.com/mints"  # Returns JSON array or line-separated mints
update_seconds = 60                   # Optional: Refresh interval
max_per_cycle = 15                    # Optional: Max mints per cycle
```

### Timestamp in URLs
The `%TIMESTAMP%` placeholder can be used in URL mints to prevent caching:
```toml
url = "https://api.example.com/mints?t=%TIMESTAMP%"
```
**How it works**:
- Automatically replaced with current milliseconds timestamp
- Ensures fresh data by bypassing CDN/browser caching
- Example generated URL: `https://api.example.com/mints?t=1634567890123`

### Mint Tags
Mints can be tagged for advanced filtering in strategies. Format:
```
<MINT_ADDRESS>,<TAG1>,<TAG2>,...
```
**Example**:
```
So11111111111111111111111111111111111111112,perps,stable
EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v,perps,stable
6p6xgHyF7AeE6TZkSmFsko444wqoP15icUSqi2jfGiPN,meme
```

**Usage in Strategies**:
```toml
# Include mints with ("perps" AND "stable") OR ("new" AND "verified")
mint_include_tags = [ ["perps", "stable"], ["new", "verified"] ]

# Exclude mints with "scam" OR ("experimental" AND "volatile")
mint_exclude_tags = [ ["scam"], ["experimental", "volatile"] ]
```

---

## 🎯 Strategy Fields

### 1.0 Quote Affecting Fields
| Field | Type | Description |
|-------|------|-------------|
| `min_spend` | float | Minimum amount to spend per swap |
| `max_spend` | float | Maximum amount to spend per swap |
| `min_priority_fee_lamports` | int | Minimum priority fee (lamports) |
| `max_priority_fee_lamports` | int | Maximum priority fee (lamports) |
| `min_priority_fee_sol` | float | Minimum priority fee (SOL) |
| `max_priority_fee_sol` | float | Maximum priority fee (SOL) |
| `priority_fee_percent` | int | Priority fee as percentage of gain (1-100) |

### 1.1 Entry Specific
| Field | Type | Description |
|-------|------|-------------|
| `entry_legacy` | bool | Use legacy Jupiter quoting method |
| `entry_direct` | bool | Alias for entry_only_direct_routes |
| `entry_only_direct_routes` | bool | Restrict to direct routes only |
| `entry_restrict_intermediate_tokens` | bool | Block intermediate tokens |
| `entry_max_accounts` | int | Max accounts for entry swap |
| `entry_dexes` | string[] | Allowed DEXs for entry |
| `entry_exclude_dexes` | string[] | Blocked DEXs for entry |

### 1.2 Exit Specific
| Field | Type | Description |
|-------|------|-------------|
| `exit_legacy` | bool | Use legacy Jupiter quoting method |
| `exit_direct` | bool | Alias for exit_only_direct_routes |
| `exit_only_direct_routes` | bool | Restrict to direct routes only |
| `exit_restrict_intermediate_tokens` | bool | Block intermediate tokens |
| `exit_max_accounts` | int | Max accounts for exit swap |
| `exit_dexes` | string[] | Allowed DEXs for exit |
| `exit_exclude_dexes` | string[] | Blocked DEXs for exit |

### 2.0 Transaction Skipping
| Field | Type | Description |
|-------|------|-------------|
| `cooldown` | string | Retry delay per token per strategy (default: "3s") |
| `cooldown_ms` | int | Retry delay per token per strategy (default: "3s") |
| `max_lookup_tables` | int | Maximum lookup tables to use (default: 4) |
| `min_swap_routes` | int | Min routes (≥2 required) |
| `max_swap_routes` | int | Maximum swap routes |

### 2.1 Gain Requirements
| Field | Type | Description |
|-------|------|-------------|
| `min_gain_bps` | int | Minimum gain in basis points |
| `min_gain_percent` | float | Minimum gain percentage |
| `min_gain_lamports` | int | Minimum gain in lamports |
| `min_gain_sol` | float | Minimum gain in SOL |

### 2.2 Error Printing
| Field | Type | Description |
|-------|------|-------------|
| `entry_quote_error_print` | bool | Print errors from entry quote requests |
| `exit_quote_error_print` | bool | Print errors from exit quote requests |
| `same_pool_error_print` | bool | Print same pool detection errors |

### 3.0 Transaction Building
| Field | Type | Description |
|-------|------|-------------|
| `cu_limit` | int | Static Compute unit limit per transaction |
| `cu_base` | int | Base compute units per transaction, avoid using with cu_limit |
| `cu_per_swap` | int | Compute units allocated per swap route, avoid using with cu_limit |

### 4.0 Jito Specific

#### 4.1 Tipping Configuration
| Field | Type | Description |
|-------|------|-------------|
| `dynamic_primary_tip_percent` | int | Primary tip % (1-100) |
| `dynamic_secondary_tip_percent` | int | Secondary tip % (1-100) |
| `dynamic_secondary_tip_chance` | int | Chance to use secondary tip (1-100) |
| `dynamic_tip` | object | Grouped dynamic tip configuration |
| `dynamic_tip_lamports` | int | Fixed tip in lamports |
| `dynamic_tip_percent` | int | Dynamic tip % (1-100) |
| `dynamic_tip_sol` | float | Fixed tip in SOL |
| `jito_enabled` | bool | Enable Jito sending |
| `jito_unwrap_tip` | bool | Unwrap WSOL for tips (SOL only) |
| `max_tip_lamports` | int | Max tip in lamports |
| `max_tip_sol` | float | Max tip in SOL |
| `static_tip_lamports` | int | Fixed tip in lamports |
| `static_tip_percent` | int | Static tip % (1-100) |
| `static_tip_sol` | float | Fixed tip in SOL |

#### 4.2 Connection Configuration
##### Common Fields
| Field | Type | Description |
|-------|------|-------------|
| `connect_timeout_ms` | int | Connection timeout in milliseconds |
| `request_timeout_ms` | int | Request timeout in milliseconds |

##### jito_unbound_grpc Specific
| Field | Type | Description |
|-------|------|-------------|
| `threads` | int | Worker threads (-1 = unbound cached pool) |
| `ips_file_path` | string | File containing IPs for binding |
| `ips_skip_count` | int | Skip first N IPs (default: 0) |
| `ips_load_count` | int | Load next M IPs (default: all) |
| `proxy_keypairs_path` | string | Path to keypairs file for pre-funded static tip wallets |

##### jito_rpc Specific
| Field | Type | Description |
|-------|------|-------------|
| `enabled` | bool | Enable this connection endpoint |
| `url` | string | Jito Block Engine URL |
| `identifier` | int | Unique numeric ID for endpoint |
| `uuid` | string | Optional Jito UUID |
| `requests_per_second` | int | Max requests per second |
| `connections` | int | Number of active connections |
| `queue_timeout_ms` | int | Timeout for queued requests |
| `priority_queue` | bool | Transactions are added to queue by gain |
| `always_queue` | bool | Always queue requests |

#### Configuration Examples

##### [[jito_unbound_grpc]] Example
```toml
[[jito_unbound_grpc]]
enabled=false
threads=0 # 0 will default to a shared "common" pool, -1 will use an unbound cached thread pool
targets=[
    { host="https://slc.mainnet.block-engine.jito.wtf", identifier=1 },
    { host="https://ny.mainnet.block-engine.jito.wtf", identifier=2 },
    { host="https://london.mainnet.block-engine.jito.wtf", identifier=3 },
]
ips_file_path="/path/to/bind-ips-or-proxies.txt"
ips_skip_count=4 # skip the first N ips (optional, defaults to 0)
#ips_load_count=999 # load the next M IPs (optional, defaults to all)

proxy_keypairs_path="/path/to/prefunded-wallets.txt"

connect_timeout_ms = 5000
request_timeout_ms = 5000
```

##### [[jito_rpc]] Jito UUID EXAMPLE
```toml
[[jito_rpc]]
enabled=true
url="https://frankfurt.mainnet.block-engine.jito.wtf"
identifier=1
uuid="your-uuid-here"
requests_per_second=10
connections=10 # warning: too many connections can slow down sending due to idle connections timing out
connect_timeout_ms = 5000
request_timeout_ms = 5000
queue_timeout_ms=1000
priority_queue=true
always_queue=false

```

##### Dynamic Tipping Examples
```toml
[[swap.strategy]]
# Simple dynamic tip (5% of profit)
dynamic_tip_percent = 5

[[swap.strategy]]
# Advanced dynamic tip configuration
dynamic_tip = {
  primary_percent = 10,    # Base tip percentage
  secondary_percent = 80,  # Boosted tip percentage
  secondary_chance = 30    # 30% chance to use boosted tip
}

[[swap.strategy]]
# Alternative individual field syntax
dynamic_primary_tip_percent = 10
dynamic_secondary_tip_percent = 80
dynamic_secondary_tip_chance = 30
```
##### Static Tipping Examples
```toml
[[swap.strategy]]
static_tip_lamports = 6900

[[swap.strategy]]
static_tip_percent= 15
```

### 5.0 Spam Specific
| Field | Type | Description |
|-------|------|-------------|
| `spam_senders` | object[] | Array of RPC sender configs |
| `spam_max_opportunity_age_ms` | int | Max opportunity age in ms |
| `spam_max_opportunity_age` | string | Alternative as duration ("100ms") |

#### Sender Configuration
```toml
[[spam_rpc]]
enabled=true
id = "test"
url = "http://123.45.67.89:8899"

```
#### Worker Configuration
```toml
busy_workers = 1    # Continuously checks for work (100% CPU, lowest latency)
spin_workers = 1    # Uses CPU hint instructions (high CPU, very low latency)
yield_workers = 1   # Yields to other threads when idle (medium CPU, moderate latency)

```

---

## 📚 Complete Examples

### Jito Example: Full Unbound GRPC Configuration
```toml
[bot_misc]
keypair_path="/path/to/keypair.json" # required for signing transactions
protect_keypair=true
acknowledge_terms_of_service=false
acknowledge_external_price_risk=false
acknowledge_experimental_release=false

[jupiter]
url="http://127.0.0.1:8080"
workers=6 # the amount of connections and threads used to make jupiter requests
connect_timeout_ms=5000
request_timeout_ms=5000

[blockhash_fetcher]
rpc_url="${DEFAULT_RPC_URL}"

[token_accounts_fetcher] # not required but encouraged
rpc_url="${DEFAULT_RPC_URL}"

[[file_mints]]
enabled=true
update_seconds=10
path="/path/to/mints.txt"

[plugin]
class="org.notarb.DefaultJito"

[[jito_unbound_grpc]]
enabled=false
threads=0 # 0 will default to a shared "common" pool, -1 will use an unbound cached thread pool
targets=[
    { host="https://slc.mainnet.block-engine.jito.wtf", identifier=1 },
    { host="https://ny.mainnet.block-engine.jito.wtf", identifier=2 },
    { host="https://london.mainnet.block-engine.jito.wtf", identifier=3 },
]
ips_file_path="/path/to/bind-ips-or-proxies.txt"
ips_skip_count=4 # skip the first N ips (optional, defaults to 0)
#ips_load_count=999 # load the next M IPs (optional, defaults to all)

proxy_keypairs_path="/path/to/prefunded-wallets.txt"

connect_timeout_ms = 5000
request_timeout_ms = 5000

[[swap]]
enabled=true
mint="SOL"

[swap.strategy_defaults]
cooldown_ms=10

# Simple dynamic tip example
[[swap.strategy]]
min_spend=0.5
max_spend=1
min_gain_lamports=20_000
dynamic_tip_percent=5  # 5% of profit as tip

# Advanced dynamic tip example
[[swap.strategy]]
min_spend=0.5
max_spend=1
min_gain_lamports=20_000
dynamic_tip = {
  primary_percent = 10,
  secondary_percent = 80,
  secondary_chance = 30
}

# Static tip example
[[swap.strategy]]
min_spend=0.5
max_spend=1
min_gain_lamports=20_000
static_tip_lamports=6900
```

### Spam Example Full Configuration
```toml
[bot_misc]
keypair_path="/path/to/keypair.json" # required for signing transactions
protect_keypair=true
acknowledge_terms_of_service=false
acknowledge_external_price_risk=false
acknowledge_experimental_release=false

[jupiter]
url="http://127.0.0.1:8080"
workers=6 # the amount of connections and threads used to make jupiter requests
connect_timeout_ms=1000
request_timeout_ms=1000

[blockhash_fetcher]
rpc_url="http://111.222.333.69:8899/"

[token_accounts_fetcher] # not required but encouraged
rpc_url="http://111.222.333.69:8899/"

[[file_mints]]
enabled=true
update_seconds=10
path="/path/to/mints.txt"

[plugin]
class="org.notarb.DefaultSpam"

[[spam_rpc]]
enabled=true
id = "test"
url = "http://123.45.67.89:8899"

# Worker configuration
busy_workers = 2    # Continuously checks for work (100% CPU, lowest latency)
spin_workers = 0    # Uses CPU hint instructions (high CPU, very low latency)
yield_workers = 0   # Yields to other threads when idle (medium CPU, moderate latency)

# HTTP options
connect_timeout_ms = 5000
request_timeout_ms = 5000
idle_timeout_ms = 10_000

## SOL (Spam)
[[swap]]
enabled=true
mint="SOL"

[swap.strategy_defaults]
cooldown_ms=10
max_opportunity_age_ms=100

[[swap.strategy]]
min_spend=0.0001
max_spend=0.1
cu_limit=369_369
min_priority_fee_lamports=187
max_priority_fee_lamports=369
min_gain_lamports=5000
spam_senders=[
    { rpc="test", skip_preflight=true, max_retries=0 },
    { rpc="test", skip_preflight=true, max_retries=0 },
]
```

### Kamino Flash Loans
```toml
[[swap.strategy]]
kamino_borrow_amount = 10.0  # The amount to borrow, must be > than spend amount

```

---

## 🔗 Official Links

- 📦 [Download NotArb](https://download.notarb.org)  
- 📊 [Dune Dashboard](https://dune.notarb.org)
- 💬 [Discord Community](https://discord.notarb.org)  
