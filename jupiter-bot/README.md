# NotArb Jupiter Bot Configuration Guide

## Overview

This guide provides detailed instructions on configuring your NotArb Jupiter Bot using the provided configuration options.

## Configuration Options (OUTDATED)

```toml
# Miscellaneous configuration (Required)
[bot_misc]
keypair_path="/path/to/keypair.json OR /path/to/keypair.txt" # Path to the keypair file used for signing transactions
swap_threads=0 # Number of threads for handling swap requests (if left 0, the bot will automatically determine an optimal amount)
jito_threads=0 # Number of threads for dispatching Jito requests. (if left 0, the bot will automatically determine an optimal amount)
spam_threads=0 # Number of threads for dispatching Spam requests. (if left 0, the bot will automatically determine an optimal amount)
acknowledge_terms_of_service=false # required to run notarb
acknowledge_external_price_risk=false # required to run notarb when trading with anything other than SOL, which require 3rd party price fetches
price_api_gecko=false # optional to use Gecko Terminal API prices instead of Jupiter Price API prices

# Jupiter configuration (Required) (You can optionally use this same exact structure with [jupiter_quote] and [jupiter_swap] to slit Jupiter load)
[jupiter]
url="http://0.0.0.0:8080/" # URL of your Jupiter server
http_timeout_ms=3000 # HTTP request timeout for Jupiter (in milliseconds)
http_pool_max_size=50 # Maximum number of HTTP connections allowed to be pooled for this dispatcher's requests (default: 5)
http_pool_keep_alive="5m" # Maximum amount of time a pooled HTTP connection can be idle for. (default: "5m")

# RPC configuration (Only required for spam sending and simulation mode)
# This is just an example, we advise changing this from solana's public rpc.
[[rpc]]
enabled=true # Enable or disable this RPC node configuration (default: true)
id="solana-pub" # Unique custom identifier for this RPC configuration
url="https://api.mainnet-beta.solana.com" # URL and port of your RPC server
http_timeout_ms=1000 # HTTP request timeout for RPC (in milliseconds)
http_pool_max_size=10 # Maximum number of HTTP connections allowed to be pooled for this dispatcher's requests (default: 5)
http_pool_keep_alive="5m" # Maximum amount of time a pooled HTTP connection can be idle for. (default: "5m")

# Jito configuration (At least one required for sending Jito transactions)
# Swaps will execute on the enabled Jito dispatcher with the least amount of requests queued.
[[jito]]
enabled=false # Enable or disable sending (default: true)
url="https://mainnet.block-engine.jito.wtf" # URL of the block engine
http_timeout_ms=3000 # HTTP request timeout (in milliseconds)
http_pool_max_size=5 # Maximum number of HTTP connections allowed to be pooled for this dispatcher's requests (default: 5)
requests_per_second=5 # Maximum number of requests per second allowed to be dispatched
queue_timeout_ms=7500 # Timeout for requests in the queue to prevent overload; ensures the queue doesn't grow faster than it is processed
always_queue=false # Set to true to make transaction requets always queue to this dispatcher no matter what. (The default behavior is to choose a dispatcher with the least amount of requests queued)
proxy_host="" # All proxy settings are optional
proxy_port=8002
proxy_user=""
proxy_password=""
proxy_wallet=false # When true, uses a separate wallet for tips. Sends 0.01 initially to cover minimum balance, refunded at transaction end.
bind_ip="" # Set this to bind outgoing requests to a specific source IP, like a lightweight proxy without an intermediary server.

# Token Accounts Fetcher (Optional)
[token_accounts_fetcher] # This allows the bot to know what token accounts are already open, allowing for faster transaction building.
enabled=false
rpc="solana-pub"

# Simulation mode (Optional)
[simulation_mode]
enabled=false
rpc="solana-pub"
skip_known_jupiter_errors=true # When true, known Jupiter errors will be skipped from output
skip_successful_responses=false # When true, successful responses will be skipped from output
skip_no_profit_responses=false # When true, no profit responses will be skipped from output
force_blockhash=true # When true, the "replaceRecentBlockhash=true" Solana variable will be set

# Wsol Unwrapper (Optional)
[wsol_unwrapper] # Requires SOL balance for network fees
enabled=false
rpc="your-rpc-id" # the rpc used for the balance check & rebalance transaction
check_minutes=1 # interval in minutes to check if an unwrap is required
min_sol=0.5 # triggers an unwrap when your sol balance is less than this number
unwrap_sol=1 # unwraps this amount of wsol to sol
priority_fee_lamports=0 # optional, but can help tx land

## Below are configurations for mint suppliers. There are currently 4 types of mint suppliers:
# [dynamic_mints] - only 1 configuration allowed
# [[static_mints]] - multiple configurations allowed
# [[file_mints]] - multiple configurations allowed
# [[url_mints]] - multiple configurations allowed
# At least one mint supplier is required for the bot to operate.
# Note: More mints may result in opening multiple token accounts, which can affect your balance due to account creation fees. Token accounts are only opened once.

## Dynamic Mints DEPRECATED - this will be removed in a later release
[dynamic_mints] # this is the only mint configuration where only one configuration is allowed, hence the single brackets
enabled=true
limit=100 # optional - limits the number of mints obtained from this supplier, ordered by highest daily volume first
export_path="dynamic-mints.txt" # optional - useful for debugging

untradable_cooldown="1m" # optional - if the bot detects an untradable token, that token will be put on a cooldown for the given duration (default 1m)
max_per_cycle=10 # optional - used to limit how many mints can be processed from this mint supplier per bot cycle (default unlimited)
update_seconds=10 # optional - this pulls from Jupiter's public endpoint, keep that in mind if running multiple bots for rate limiting (default 10, min 5)

exclude=[ # optional
  "So11111111111111111111111111111111111111112",  # sol
  "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB", # usdt
  "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v", # usdc
]

## NOTE: Filter configurations must be placed at the end, after other settings like exclude and enabled. ##

[[dynamic_mints.filter]] # example filter to pick up all mints with either a birdeye-trending tag OR pump and verified tags
include_tags=[ # an array of tag groups, only one group match required to be included
  ["birdeye-trending"],
  ["pump", "verified"]
]

[[dynamic_mints.filter]] # example filter to pick up new mints
max_age="3d" # d=days, h=hours, m=minutes
min_daily_volume=10_000
exclude_tags=[ # an array of tag groups, only one group match is required to be excluded
  ["strict"],
  ["community"]
] # Juptier token tags can be found here: https://station.jup.ag/docs/token-list/token-list-api

## Static Mints
[[static_mints]] # double brackets since we allow multiple
enabled=true
untradable_cooldown="1m" # optional - if the bot detects an untradable token, that token will be put on a cooldown for the given duration (default 1m)
max_per_cycle=10 # optional - use this to limit how many mints can be processed from this mint supplier per bot cycle (default unlimited)
random_order=false # optional - use this to randomize the order of the list every cycle (default false)
list=[
  "So11111111111111111111111111111111111111112",  # sol
  "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB", # usdt
  "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v", # usdc
]

## File Mints
[[file_mints]]
enabled=true
untradable_cooldown="1m" # if the bot detects an untradable token, that token will be put on a cooldown for the given duration (default 1m)
max_per_cycle=10 # optional - use this to limit how many mints can be processed from this mint supplier per bot cycle (default unlimited)
random_order=false # optional - use this to randomize the order of the list every cycle (default false)
update_seconds=10 # optional - when set, this file will be loaded every X amount of seconds (default 0)
path="/absolute/path/to/mints.json OR /absolute/path/to/mints.txt" # the actual extension here doesn't matter, as long as the output is either a json list of strings or raw text of 1 mint per line (raw text supports # comments)

## URL Mints
[[url_mints]]
enabled=true
untradable_cooldown="1m" # optional - if the bot detects an untradable token, that token will be put on a cooldown for the given duration (default 1m)
max_per_cycle=10 # optional - use this to limit how many mints can be processed from this mint supplier per bot cycle (default unlimited)
random_order=false # optional - use this to randomize the order of the list every cycle (default false)
update_seconds=10 # optional - when set, this url will be loaded every X amount of seconds (default 0)
url="http://yoururl.com/mints.txt OR http://yoururl.com/mints.json" # the actual extension here doesn't matter, as long as the output is either a json list of strings or raw text of 1 mint per line (raw text supports # comments)

## Below are configurations for swaps with very basic placeholder settings.
## For proper example configurations, refer to: https://examples.notarb.org/

## Swap config (At least one required)
[[swap]]
enabled=true # Enable or disable this swap configuration (default: true)
mint="So11111111111111111111111111111111111111112" # Base mint to trade (can also do symbols: SOL, USDC, USDT)

[swap.strategy_defaults] # Default strategy configuration for all of this swap's strategies
wrap_unwrap_sol=false 
jito_enabled=true
cooldown="3s"
# Refer to Strategy Fields below #

[[swap.strategy]]
enabled=true
min_spend=0.001 
max_spend=0.01
cu_limit=250_000 # If not set, the bot will set this value for you. (This is advised for Jito)
min_gain_bps=20 # Minimum _estimated_ gain required in bps; note that the actual profit may vary by the time the transaction lands. Consider starting with a higher value to be safe.
min_priority_fee_lamports=190 # Alternatively you can use min_priority_fee_sol
max_priority_fee_lamports=190 # Alternatively you can use max_priority_fee_sol
spam_senders=[ # Normal transaction senders list
    { rpc="solana-pub", skip_preflight=true, max_retries=0, unique=false },
]
spam_max_opportunity_age_ms=100 # The maximum amount of time allowed from when the opportunity was found. (default: 1000) (The name of this may change in the future)
# Refer to Strategy Fields below #
```

## Strategy Fields

#### 1.0. Fields that will directly affect the results of Jupiter entry/exit quotes:
- `min_spend`: The minimum amount to spend per swap operation.
- `max_spend`: The maximum amount to spend per swap operation.
- `min_priority_fee_lamports`: The minimum priority fee for transactions in lamports.
  - Alternatively, you can use `min_priority_fee_sol` which will do the lamport conversion for you.
- `max_priority_fee_lamports`: The maximum priority fee for transactions in lamports.
  - Alternatively, you can use `max_priority_fee_sol` which will do the lamport conversion for you.
##### 1.1. Entry specific:
- `entry_only_direct_routes`: Restrict the entry swaps to direct routes only.
- `entry_restrict_intermediate_tokens`: Restrict the use of intermediate tokens during entry swaps.
- `entry_max_accounts`: The maximum number of accounts that can be used for entry swaps.
  - Alternatively, you can use `total_max_accounts` to limit total accounts instead.
- `entry_dexes`: A list of DEXes allowed for entry swaps.
- `entry_exclude_dexes`: A list of DEXes to exclude from entry swaps.
##### 1.2. Exit specific: (The same as above, but specific to exit quotes)
- `exit_only_direct_routes`: Restrict the exit swaps to direct routes only.
- `exit_restrict_intermediate_tokens`: Restrict the use of intermediate tokens during exit swaps.
- `exit_max_accounts`: The maximum number of accounts that can be used for exit swaps.
  - Alternatively, you can use `total_max_accounts` to limit total accounts instead.
- `exit_dexes`: A list of DEXes allowed for exit swaps.
- `exit_exclude_dexes`: A list of DEXes to exclude from exit swaps.
---
#### 2.0. Fields that will determine if a transaction will be skipped, after quotes are acquired:
- `cooldown`: The waiting period before attempting the same token opportunity again for the given strategy. (default: "3s")
- `min_swap_routes`: The minimum number of swap routes allowed. (Should never be less than 2)
- `max_swap_routes`: The maximum number of swap routes allowed.
- `max_price_impact`: The maximum price impact allowed. (Price impact is returned from Jupiter quotes. Price impact is represented as a percentage. Ex: 0.05 = 5%)
##### 2.1. Gain requirements:
- `min_gain_bps`: The minimum _estimated_ token gain [bps](https://www.investopedia.com/ask/answers/what-basis-point-bps) required.
- `min_gain_percent`: The minimum _estimated_ token gain percentage required.
- `min_gain_lamports`: The minimum _estimated_ token gain converted to lamports required.
- `min_gain_sol`: The minimum _estimated_ token gain converted to solana required.
---
#### 3.0. Fields that will directly affect the building of transactions:
- `wrap_unwrap_sol`: Whether to automatically wrap and unwrap SOL for transactions. (default: false)
- `skip_user_accounts_rpc_calls`: Only use if you're 100% certain every trade will only use tokens you have accounts open for. (default: false)
- `cu_limit`: The cu limit to set per transaction. (If you're unsure, leave unset.)
---
#### 4.0. Jito specific fields:
- `jito_enabled`: Enable or disable Jito sending.
- `jito_unwrap_tip`: When true, WSOL will be unwrapped on-chain to pay your Jito tip. This is only applicable when your base is Solana.
- `jito_dynamic_tip_percent`: (1-100) When > 0, Jito transactions will be sent with dynamic tips based on true profit.
- `jito_static_tip_percent`: (1-100) When > 0, Jito transactions will be sent with static tips based on quoted profit.
- `jito_max_tip_lamports`: The maximum Jito tip allowed when using tip percentages.
  - Alternatively, you can use `jito_max_tip_sol` which will do the lamport conversion for you.
- `jito_static_tip_lamports`: When > 0, Jito transactions will be sent with a predefined static tip.
  - Alternatively, you can use `jito_static_tip_sol` which will do the lamport conversion for you.
  - Using `jito_static_tip_percent` will override this field.
---
#### 5.0. Spam specific fields:
- `spam_senders`: A list of spam transaction senders, which consist of rpc, skip_preflight, and max_retries.
- `spam_max_opportunity_age_ms`: The maximum amount of time allowed from when the opportunity was found.

## Swap Mints

The following mints can be used as swap bases:

| Symbol     | Address                                        |
|:-----------|:-----------------------------------------------|
| SOL        | `So11111111111111111111111111111111111111112`  |
| USDC       | `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` |
| USDT       | `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` |
| PYUSD      | `2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo` |
| WBTC       | `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` |
| WETH       | `7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs` |
| JUP        | `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN`  |
| RAY        | `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` |
| ORCA       | `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE`  |
| BONK       | `DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263` |
| SOLARBA    | `6Qd6mmFR84jzg24S3851TWNGeTTFrfPko76UiHyRMDMT` |
| WIF        | `EKpQGSJtjMFqKZ9KQanSqYXRcF8fBopzLHYxdM65zcjm` |
| WEN        | `WENWENvqqNya429ubCdR81ZmD69brwQaaBYY6p3LCpk`  |
| PYTH       | `HZ1JovNiVvGrGNiiYvEozEVgZ58xaU3RKwX8eACQBCt3` |
| INF        | `5oVNBeEEQvYi1cX3ir8Dx5n1P7pdxydbGF2X4TxVusJm` |
| POPCAT     | `7GCihgDB8fe6KNjn2MYtkzZcRjQy3t9GHdC8uHYmW2hr` |
| JSOL       | `7Q2afV64in6N6SeZsAAB81TJzwDoD6zpqmHkzi9Dcavn` |
| MSOL       | `mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So`  |
| JLP        | `27G8MtK7VtTcCHkpASjSDdkWWYfoqT6ggEuKidVJidD4` |
| GUAC       | `AZsHEMXd36Bj1EMNXhowJajpUXzrKcK57wW4ZGXVa7yR` |
| BSOL       | `bSo13r4TkiE4KumL71LsHTPpL2euBYLFx6h9HP3piy1`  |
| APE        | `DF5yCVTfhVwvS1VRfHETNzEeh1n6DjAqEBs3kj9frdAr` |
| MOUTAI     | `45EgCwcPXYagBC7KqBin4nCFgEZWN7f3Y6nACwxqMCWX` |
| MNDE       | `MNDEFzGvMt87ueuHvVU9VcTqsAP5b3fTGPsHuuPA5ey`  |
| JITOSOL    | `J1toso1uCk3RLmjorhTtrVwY9HJ7X8V9yYac6Y7kGCPn` |
| JTO        | `jtojtomepa8beP8AuQc6eXt5FriJwfFMwQx2v2f9mCL`  |
| USDH       | `USDH1SM1ojwWUga67PGrgFWUHibbjqMvuMaDkRJTgkX`  |
| WSTETH     | `ZScHuTtqZukUrtZS43teTKGs2VqkKL8k4QCouR2n6Uo`  |
| KMNO       | `KMNo3nJsBXfcpJTVhZcXLW7RmTwTt4GVFE7suUBo9sS`  |
| MPLX       | `METAewgxyPbgwsseH8T16a39CQ5VyVxZi9zXiDPY18m`  |
| W          | `85VBFQZC9TZkfaptBWjvUw7YbZjy52A6mjtPGjstQAmQ` |
| GME        | `8wXtPeU6557ETkp9WHFY1n1EcU6NxDvbAggHGsMYiHsB` |
| PONKE      | `5z3EqYQo9HiCEs3R84RCDMu2n7anpDMxRhdK8PSWmrRC` |
| MYRO       | `HhJpBhRRn4g56VsyLuT8DL5Bv31HkXqsrahTTUCZeZg4` |
| BOME       | `ukHH6c7mMyiWCf1b9pnWe25TSpkDDt3H5pQZgZ74J82`  |
| SLERF      | `7BgBvyjrZX1YKz4oh9mjb8ZScatkkwb8DzFx7LoiVkM3` |
| STSOL      | `7dHbWXmci3dT8UFYWYZweBLXgycu7Y3iL6trKn1Y7ARj` |
| HNT        | `hntyVP6YFm1Hg25TN9WGLqM12b8TQmcknKrdu1oxWux`  |
| MEW        | `MEW1gQWJ3nEXg2qgERiKu7FAFj79PHvQVREQUzScPP5`  |
| DSOL       | `Dso1bDeDjCQxTrWHqUUi63oBvV7Mdm6WaobLbQ7gnPQ`  |
| DRIFT      | `DriFtupJYLTosbwoN8koMbEYSx54aFAVLddWsbksjwg7` |
| TENSOR     | `TNSRxcUxoT9xBG3de7PiJyTDYu7kskLqcpddxnEJAS6`  |
| STEP       | `StepAscQoEioFxxWGnh2sLBDFp9d8rvKz2Yp39iDpyT`  |
| STEPSOL    | `StPsoHokZryePePFV8N7iXvfEmgUoJ87rivABX7gaW6`  |
| XSTEP      | `xStpgUCss9piqeFUk2iLVcvJEGhAdJxJQuwLkXP555G`  |
| MOTHER     | `3S8qX1MsMqRbiwKg2cQyx7nis1oHMgaCuc9c4VfvVdPN` |
| MOODENG    | `ED5nyyWEzpPPiWimP8vYm7sD7TD3LAt3Q3gRTWHzPJBY` |
| RENDER     | `rndrizKT3MK1iimdxRdWabcF7Zg7AR5T4nud4EkHBof`  |
| ATLAS      | `ATLASXmbPQxBUYbxPsV97usA3fPQYEqzQBUHgiFCUsXx` |
| POLIS      | `poLisWXnNRwC6oBu1vHiuKQzFjGL4XDSu4g9qjz9qVk`  |
| SHDW       | `SHDWyBxihqiCj6YekG2GUr7wqKLeLAMK1gHZck9pL6y`  |
| SBR        | `Saber2gLauYim4Mvftnrasomsv6NvAuncvMEZwcLpD1`  |
| MOBILE     | `mb1eu7TzEc71KxDpsmsKoucSSuuoGLv1drys1oP2jh6`  |
| HSOL       | `he1iusmfkpAdwvxLNGV8Y1iSbj4rUy6yMhEA3fotn9A`  |
| IOT        | `iotEVVZLEywoTn1QdwNPddxPWszn3zFhEot3MfL9fns`  |
| KIN        | `kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6`  |
| PRCL       | `4LLbsb5ReP3yEtYzmXewyGjcir5uXtKFURtaEUVC2AHs` |
| ZEX        | `ZEXy1pqteRu3n13kdyh4LwPQknkFk3GzmMYMuNadWPo`  |
| ISC        | `J9BcrQfX4p9D1bvLzRNCbMDv8f44a9LFdeqNE4Yk2WMD` |
| DIO        | `BiDB55p4G3n1fGhwKFpxsokBMqgctL4qnZpDH1bVQxMD` |
| SNS        | `SNSNkV9zfG5ZKWQs6x4hxvBRV6s8SqMfSGCtECDvdMd`  |
| IO         | `BZLbGTNCSFfoth2GYDtwr7e4imWzpR5jqcUuGEwr646K` |
| RAPR       | `RAPRz9fd87y9qcBGj1VVqUbbUM6DaBggSDA58zc3N2b`  |
| 7STAR      | `FDRBwha8GtiR55BPz6Ucc9ThRtjFynZqgX1UvbV72bB8` |
| SRM        | `SRMuApVNdxXokk5GT7XD5cUUgXMBCoAz2LHeuAoKWRt`  |
| PURPE      | `HBoNJ5v8g71s2boRivrHnfSB5MVPLDHHyVjruPfhGkvL` |
| 21BTC      | `21BTCo9hWHjGYYUQQLqjLgDBxjcn8vDt4Zic7TB3UbNE` |
| TBTC       | `6DNSN2BJsaPFdFFc1zP37kkeNe4Usc1Sqkzr9C9vPWcU` |
| BUSD_W     | `5RpUwQ8wtdPCZHhu6MERp2RGrpobsbZ6MH5dDHkUjs2`  |
| DAI_W      | `EjmyN6qEC1Tf1JxiG1ae7UTJhUxSwk1TCWNWqxWV4J6o` |
| USDT_W     | `Dn4noZ5jgGfkntzcQSUZ8czkreiZ1ForXYoV2H8Dm7S1` |
| USDC_W     | `A9mUU4qviSctJVPJdBJWkb28deg915LYJKrzQ19ji3FM` |
| PAI        | `Ea5SjE2Y6yvCeW5dYTn7PYMuW5ikXkvbGdcmSnXeaLjS` |
| SHIB_W     | `CiKu4eHsVrc1eueVQeHn7qhXTcVu95gSQmBpX4utjL9z` |
| UXD        | `7kbnvuGBxxj8AG9qp8Scn56muWGaRaFqxg1FsRp3PaFT` |
| SUSDC9     | `JEFFSQ3s8T3wKsvp4tnRAsUBW7Cqgnf8ukBZC4C8XBm1` |
| SUSDC8     | `88881Hu2jGMfCs9tMu5Rr7Ah7WBNBuXqde4nR5ZmKYYy` |
| FUSDC      | `Ez2zVjw85tZan1ycnJ5PywNNxR6Gm4jbXQtZKyQNu3Lv` |
| WBTC_S     | `9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E` |
| FTT_S      | `AGFEad2et2ZJif9jaGpdMixQqvW5i81aBdvKe7PHNfz3` |
| WETH_S     | `2FPyTwcZLUg1MDrwsyoP4D6s1tM7hAkHYRjkNb5w6Pxk` |
| WETH_SABER | `KNVfdSJyq1pRQk9AKKv1g5uyGuk6wpm4WG16Bjuwdma`  |
| HUBSOL     | `HUBsveNpjo5pWqNkH57QzxjQASdTVXcSK7bVKTSZtcSX` |
| BONKSOL    | `BonK1YhkXEGLZzwtcvRTip3gAL9nCeQD7ppZBLXhtTs`  |
| JUCYSOL    | `jucy5XJ76pHVvtPZb5TKRcGQExkwit2P5s4vY8UzmpC`  |
| PICOSOL    | `picobAEvs6w7QEknPce34wAE4gknZA9v5tTonnmHYdX`  |
| PWRSOL     | `pWrSoLAhue6jUxUkbWgmEy5rD9VJzkFmvfTDV5KgNuu`  |
| VSOL       | `vSoLxydx6akxyMD9XEcPvGYNGq6Nn66oqVb3UkGkei7`  |
| JUPSOL     | `jupSoLaHXQiZZTSfEWMTRRgpnyFm8f6sZdosWBjx93v`  |
| CSOL       | `Comp4ssDzXcLeu2MnLuGNNFC4cmLPMng8qWHPvzAMU1h` |
| STRONGSOL  | `strng7mqqc1MBJJV6vMzYbEqnwVGvKKGKedeCvtktWA`  |
| CLOUD      | `CLoUDKc4Ane7HeQcPpE3YHnznRxhMimJ4MyaUqyHFzAu` |
| LOCKEDBONK | `FYUjeMAFjbTzdMG91RSW5P4HT2sT7qzJQgDPiPG9ez9o` |
| BBSOL      | `Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B` |
| GIGA       | `63LfDmNb3MQ8mw9MtZ2To9bEA2M71kZUUGq5tiJxcqj9` |
| GOAT       | `CzLSujWBLFsSjncfkh59rUFqvafWcY5tzedWJSuypump` |
| ROT        | `APoM2sXUzdRHTkUjXSsdUheX1wPPdP4HFLotmtRNMU8P` |
| MEDUSA     | `Fosp9yoXQBdx8YqyURZePYzgpCnxp9XsfnQq69DRvvU4` |
| DBR        | `DBRiDgJAMsM95moTzJs7M9LnkGErpbv9v6CUR1DXnUu5` |
| WYAC       | `BEgBsVSKJSxreiCE1XmWWq8arnwit7xDqQXSWYgay9xP` |
| FWOG       | `A8C3xuqscfmyLrte3VmTqrAq8kgMASius9AFNANwpump` |
| MANEKI     | `25hAyBQfoDhfWx9ay6rarbgvWGwDdNqcHsXS3jQ3mTDJ` |
| USA        | `69kdRLyP5DTRkpHraaSZAQbWmAwzF9guKjZfzMXzcbAs` |
| LOCKIN     | `8Ki8DpuWNxu9VsS3kQbarsCWMcFGWkzzA8pUPto9zBd5` |
| MUMU       | `5LafQUrVco6o7KMz42eqVEJ9LW31StPyGjeeu5sKoMtA` |
| AURA       | `DtR4D9FtVoTX2569gaL837ZgrB6wNjj6tkmnX9Rdk9B2` |
| BOBA       | `bobaM3u8QmqZhY1HwAtnvze9DLXvkgKYk3td3t8MLva`  |
| DADDY      | `4Cnk9EPnW5ixfLZatCPJjDB1PUtcRpVVgTQukm9epump` |
| PUPS       | `2oGLxYuNBJRcepT1mEV6KnETaLD7Bf6qq3CM6skasBfe` |
| NUB        | `GtDZKAqvMZMnti46ZewMiXCa4oXF4bZxwQPoKzXPFxZn` |
| SSOL       | `sSo14endRuUbvQaJS3dq36Q829a3A6BEfoeeRGJywEh`  |
| USEDCAR    | `9gwTegFJJErDpWJKjPfLr2g2zrE3nL1v5zpwbtsk3c6P` |
| SNOOFI     | `7M9KJcPNC65ShLDmJmTNhVFcuY95Y1VMeYngKgt67D1t` |
| TREMP      | `FU1q8vJpZNUrmqsciSjp8bAKKidGsLmouB8CBdf8TKQv` |
| WOLF       | `Faf89929Ni9fbg4gmVZTca7eW6NFg877Jqn6MizT3Gvw` |
| HARAMBE    | `Fch1oixTPri8zxBnmdCEADoJW2toyFHxqDZacQkwdvSP` |
| BRAINLET   | `8NNXWrWVctNw1UFeaBypffimTdcLCcD8XJzHvYsmgwpF` |
| SC         | `6D7NaB2xsLd7cauWu1wKk6KBsJohJmP2qZH9GEfVi5Ui` |
| RETARDIO   | `6ogzHhzdrQr9Pgv6hZ2MNze7UrzBMAFyBBWUYp1Fhitx` |
| MICHI      | `5mbK36SZ7J19An8jFochhQS4of8g6BwUjbeCSxBSoWdp` |
| PNUT       | `2qEHjDLDLbuBgRYvsxhc5D6uDWAivNFZGan56P1tpump` |
| CBBTC      | `cbbtcf3aa214zXHbiAZQwf4122FBYbraNdFqgw4iMij`  |
| MEMESAI    | `39qibQxVzemuZTEvjSB7NePhw9WyyHdQCqP8xmBMpump` |
| BILLY      | `3B5wuUrMEi5yATD7on46hKfej3pfmd7t1RKgrsN3pump` |
| HAPPY      | `HAPPYwgFcjEJDzRtfWE6tiHE9zGdzpNky2FvjPHsvvGZ` |
| AI16Z      | `HeLp6NuQkmYB4pYWo2zYs22mESHXPQYzXbB8n4V98jwC` |
| GNON       | `HeJUFDxfJSzYFUuHLxkMqCgytU31G6mjP4wKviwqpump` |
| BUU        | `28tVhteKZkzzWjrdHGXzxfm4SQkhrDrjLur9TYCDVULE` |
| SHOGGOTH   | `H2c31USxu35MDkBrGph8pUDUnmzo2e4Rf4hnvL2Upump` |
| GRWR       | `8cdKqQsEaa1L6tCavTTtCYqhMTwxe1BiBR2rMnjivb4k` |
| GRASS      | `Grass7B4RdKfBCjTKgSqnXkqjwiGvQyFbuSCUJr3XXjs` |
| SIGMA      | `5SVG3T9CNQsm2kEwzbRq6hASqh1oGfjqTtLXYUibpump` |
| MIST       | `FjTJCCQpLU4fpH58mN1bTQXiQsjJVYai3QYFjYqYpump` |
| LUCE       | `CBdCxKo9QavR9hfShgpEBG3zekorAeD7W1jfq2o3pump` |
| PIPPIN     | `Dfh5DzRgSvvCFDoYc2ciTkMrbDfRKybA4SoFbPmApump` |
| CENT       | `C9FVTtx4WxgHmz55FEvQgykq8rqiLS8xRBVgqQVtpump` |
| EARL       | `BjjvKX5k7gQoGRmvQAA5WMr7EkQ2cirGTSGxAznDpump` |
| TOAD       | `FViMp5phQH2bX81S7Yyn1yXjj3BRddFBNcMCbTH8FCze` |
| NOMNOM     | `6ZrYhkwvoYE4QqzpdzJ7htEHwT2u2546EkTNJ7qepump` |
| PROJECT89  | `Bz4MhmVRQENiCou7ZpJ575wpjNFjBjVBSiVhuNg1pump` |
| GINNAN     | `GinNabffZL4fUj9Vactxha74GDAW8kDPGaHqMtMzps2f` |
| ZEUS       | `ZEUS1aR7aX8DFFJf5QjWj2ftDDdNTroMNGo8YoQm3Gq`  |
| MINI       | `2JcXacFwt9mVAwBQ5nZkYwCyXQkRcdsYrDXn6hj22SbP` |
| SELFIE     | `9WPTUkh8fKuCnepRWoPYLH3aK9gSjPHFDenBq2X1Czdp` |
| HAGGIS     | `U237C8hKyZYL42TEtTv6JGtdwDr3pZaQeeWMCVVpump`  |
| NOS        | `nosXBVoaCTtYdLvKY6Csb4AC8JCdQKKAaWYtx2ZMoo7`  |
| CATANA     | `GmbC2HgWpHpq9SHnmEXZNT5e1zgcU9oASDqbAkGTpump` |
| OPUS       | `9JhFqCA21MoAXs2PTaeqNQp2XngPn1PgYr2rsEVCpump` |
| WDOG       | `GYKmdfcUmZVrqfcH1g579BGjuzSRijj3LBuwv79rpump` |
| EURC       | `HzwqbKZw8HxMN6bF2yFZNrht3c2iXXzpKcFu7uBEDKtr` |
| USDS       | `USDSwr9ApdHk5bvJKMjzff41FfuX8bSxdKcR81vTwcA`  |
| CHILLGUY   | `Df6yfrKC8kZE3KNkrHERKzAetSxbrWeniQfyJY4Jpump` |
| SPX6900    | `J3NKxxXZcnNiMjKw9hYb2K4LUxgwB6t1FtPtQVsv3KFr` |
| FRED       | `CNvitvFnSM5ed6K28RUNSaAjqqz5tX1rA5HgaBN9pump` |
| ELIZA      | `5voS9evDjxF589WuEub5i4ti7FWQmZCsAsyD5ucbuRqM` |
| RIF        | `GJtJuWD9qYcCkrwMBmtY1tpapV1sKfB2zUv9Q4aqpump` |
| VVAIFU     | `FQ1tyso61AH1tzodyJfSwmzsD3GToybbRNoZxUBz21p8` |
| ZEREBRO    | `8x5VqbHA8D7NkD52uNuS5nnt3PwA8pLD34ymskeSo2Wn` |
| TRUMP      | `6p6xgHyF7AeE6TZkSmFsko444wqoP15icUSqi2jfGiPN` |
| MELANIA    | `FUAfBo2jgks6gB4Z4LfZkqSZgzNucisEHqnNebaRxM1P` |
| ZBTC       | `zBTCug3er3tLyffELcvDNrKkCymbPWysGcWihESYfLg`  |
| FDUSD      | `9zNQRsGLjNKwCUU5Gq5LR8beUCPzQMVMqKAi3SSZh54u` |
| USDG       | `2u1tszSeqZ3qBWF3uNGPFc8TzMk2tdiwknnRMWGWjGWH` |