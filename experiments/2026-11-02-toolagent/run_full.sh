#!/bin/bash
set -u
cd /root/mooncake-ws/toolagent-full-fixed-20261102
export PYTHONHASHSEED=0 OMP_NUM_THREADS=2
python3 - <<'PY'
from pathlib import Path
from urllib.request import urlopen
for name,port in [('master',9014),('vllm',18148)]:
 Path('before_'+name+'.prom').write_bytes(urlopen(f'http://127.0.0.1:{port}/metrics',timeout=10).read())
PY
vllm bench serve --model store-llama --tokenizer /models/Meta-Llama-3.1-8B-Instruct --dataset-name timed_trace --num-prompts 23608 --host 127.0.0.1 --port 18148 --dataset-path /root/mooncake-ws/src/Mooncake/FAST25-release/traces/toolagent_trace.jsonl --ignore-eos --self-timed --timed-trace-chunk-hash-size 512 --timed-trace-sec-multiplier 0.001 --save-result --save-detailed --result-dir /root/mooncake-ws/toolagent-full-fixed-20261102 --result-filename result.json >benchmark.log 2>&1
rc=$?
echo "$rc" > benchmark.exit
python3 - <<'PY'
from pathlib import Path
from urllib.request import urlopen
for name,port in [('master',9014),('vllm',18148)]:
 try: Path('after_'+name+'.prom').write_bytes(urlopen(f'http://127.0.0.1:{port}/metrics',timeout=10).read())
 except Exception as e: print(name,e)
PY
exit "$rc"
