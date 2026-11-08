#!/bin/bash
set -e
source /root/mooncake-ws/install/mooncake-387aecb/env.sh
export MOONCAKE_CONFIG_PATH=/root/mooncake-ws/toolagent-full-fixed-20261102/mooncake.json
export PYTHONHASHSEED=0 OMP_NUM_THREADS=2
exec vllm serve /models/Meta-Llama-3.1-8B-Instruct --host 127.0.0.1 --port 18148 --served-model-name store-llama --max-model-len 131072 --enforce-eager --block-size 128 --gpu-memory-utilization 0.9 --no-enable-prefix-caching --max-num-batched-tokens 8192 --max-num-seqs 4 --kv-transfer-config '{"kv_connector":"AscendStoreConnector","kv_role":"kv_both","kv_connector_extra_config":{"lookup_rpc_port":"0","backend":"mooncake"}}'
