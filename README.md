# Mooncake 昇腾实验记录

记录在 Ascend 环境中使用 vLLM-Ascend 和 Mooncake Store 研究 KV Cache 分层管理、缓存复用及文件卸载的实验材料。当前处于调研和机制验证阶段。

## 周报与证据

| 时间 | 材料 | 实验状态 |
| --- | --- | --- |
| 2026-11-02 至 2026-11-08 | [周报](reports/2026-11-02--2026-11-08.md) | 新版 Store 回放及故障分析 |
| 2026-11-02 | [Tool & Agent 全量回放](experiments/2026-11-02-toolagent/README.md) | 23,608 条请求，1,702 条成功，21,906 条失败 |

研究使用的代码来自 [vLLM-HUST/mooncake-hust](https://github.com/vLLM-HUST/mooncake-hust) 及其相关实验环境。本仓库用于保存个人实验记录。实验运行时的 Mooncake master 版本由日志记录为 `0.3.13 (git: 387aecb)`。

材料由 AI 辅助从本地实验文件整理，数值已与原始结果核对。所有性能数字均需结合失败率和实验条件解读。
