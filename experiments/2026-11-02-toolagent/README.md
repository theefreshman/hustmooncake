# Tool & Agent 全量回放记录

实验于 2026-11-02 运行，材料于 2026-11-08 根据本地归档整理。目标是验证 vLLM-Ascend 经 AscendStoreConnector 使用 Mooncake Store 进行文件卸载的完整回放流程。

## 配置与证据对应

| 项目 | 记录值 | 证据 |
| --- | --- | --- |
| 模型 | Meta-Llama-3.1-8B-Instruct | [启动脚本](start-vllm.sh) |
| 推理引擎 | vLLM-Ascend，原始启动日志报告 vLLM 0.23.0 | 本地归档 vllm.log |
| Mooncake master | 0.3.13，git 387aecb | [版本日志摘录](evidence-excerpts.txt) |
| Store 安装路径 | 启动脚本加载 mooncake-387aecb/env.sh | [启动脚本](start-vllm.sh) |
| 连接器 | AscendStoreConnector，Mooncake 后端，协议 ascend | [启动脚本](start-vllm.sh)、[Store 配置](mooncake.json) |
| 模型上下文上限 | 131,072 tokens | [启动脚本](start-vllm.sh) |
| 本地前缀缓存 | 关闭 | [启动脚本](start-vllm.sh) |
| Store 内存配置 | global_segment_size 为 32GB | [Store 配置](mooncake.json) |
| 文件卸载 | enable_ssd_offload 为 true | [Store 配置](mooncake.json) |
| 负载 | FAST25-release/traces/toolagent_trace.jsonl，23,608 条 | [回放脚本](run_full.sh) |
| 回放方式 | timed_trace，self-timed，hash chunk 为 512，时间倍率 0.001 | [回放脚本](run_full.sh) |
| 客户端并发上限 | max_concurrency 为 null | [结果摘要](result-summary.json) |
| 服务端序列上限 | max_num_seqs 为 4 | [启动脚本](start-vllm.sh) |

启动脚本和 master 版本日志分别记录安装路径选择及 master 的实际版本。独立核验 vLLM 已加载的动态库，需要运行时进程映射等记录；该记录未包含在本次本地归档中。

## 回放结果

| 项目 | 数值 |
| --- | --- |
| 请求总数 | 23,608 |
| 成功请求 | 1,702 |
| 失败请求 | 21,906 |
| 回放耗时 | 8,334.607 秒，约 2.32 小时 |
| 报告的峰值并发请求 | 1,015 |
| Too many open files 错误 | 21,905 条 |
| 未收到有效 TTFT 数据块 | 1 条 |
| benchmark 进程退出码 | 0 |

这些数值可在[结果摘要](result-summary.json)、[日志摘录](evidence-excerpts.txt)及[退出码文件](benchmark.exit)交叉核对。进程退出码为 0 的同时，逐请求统计仍记录了大量失败。

当前结果支撑回放已执行和客户端文件描述符资源耗尽的故障判断。由于成功覆盖有限，本轮吞吐与延迟仅描述此次失败运行。正式性能基线、独立 Store 查询延迟及卸载收益仍待对照实验量化。

配置中启用了名为 SSD offload 的选项。根据此前环境核查，实际目录位于 Longhorn 卷，其底层物理介质尚未确认；本记录称其为文件卸载层。

## 文件来源与核验

- `start-vllm.sh`、`run_full.sh`、`mooncake.json`、`benchmark.exit` 来自原始归档，仅统一为 LF 换行。
- `result-summary.json` 保留原始 `result.json` 的指定顶层字段。`error_counts` 按每个非空 `errors` 元素的最后一行聚合。核验时满足成功数加失败数等于请求总数，错误计数之和等于失败数。
- `evidence-excerpts.txt` 收录 master 版本行、benchmark 结尾统计和错误分类。日志片段标注原始行号。
- [source-manifest.json](source-manifest.json) 记录原始文件在换行规范化之前的字节数及 SHA-256，可用于匹配本地归档。大型原始日志和逐请求结果保存在本地。

## 后续复测

现有脚本保留当次实验的绝对路径和参数，复用时需要准备相应的模型、trace、安装目录、环境文件以及运行中的 master，并调整路径。复测拟显式限制客户端并发，检查文件描述符用量、Store 写入失败和文件层容量，保存新的完整结果。

材料由 AI 辅助提取和撰写。整理过程核对了结果统计、JSON 格式、文本格式和文件大小；本机未安装 pre-commit。
