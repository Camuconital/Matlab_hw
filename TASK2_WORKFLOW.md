# Task 2 完整流程说明（M-QAM 数据传输）

本文档配合 `task2_build_model.m` 使用，帮助你完整完成 README 里 Task 2 的全部要求。

## 1) 一键搭建模型

1. 打开 MATLAB，切换到仓库目录。
2. 运行：
   ```matlab
   task2_build_model
   ```
3. 脚本会自动生成 `task2_mqam_txrx.slx`，并包含以下核心模块（已做 R2022b 兼容候选路径处理）：
   - Random Integer Generator
   - Rectangular QAM Modulator Baseband
   - AWGN Channel
   - Rectangular QAM Demodulator Baseband
   - Integer to Bit Converter（TX/RX 各一个）
   - Error Rate Calculation
   - Constellation Diagram

## 2) 按作业要求设置实验工况

你需要至少覆盖两类工况：

- **无噪声工况**：将 `AWGN Channel` 的 `SNR` 设为非常大（例如 100 dB）近似 noiseless。
- **有噪声工况**：选代表性的 Eb/No（例如 4、8、12 dB）观察星座图变化。

并对每个调制阶数分别做：
- `M = 4`
- `M = 16`
- `M = 64`

> 建议：每个 M 下至少保存 1 张无噪声星座图 + 2~3 张有噪声星座图。

## 3) BER vs Eb/No 扫描流程（核心评分点）

建议新建一个 MATLAB 脚本（例如 `task2_ber_sweep.m`）做自动扫描：

- 扫描范围：`EbNoVec = 0:2:20`（可按老师要求调整）
- 对每个 `M in [4 16 64]`：
  1. 设置模型工作区参数 `M`、`k=log2(M)`
  2. 循环写入 `EbNo_dB`
  3. `sim('task2_mqam_txrx')`
  4. 从 `Error Rate Calculation` 输出读取 BER
  5. 存入数组，最后统一绘图

最终得到一张图，三条 BER 曲线（M=4,16,64）同图对比。

## 4) 带宽效率计算（必须写进报告）

QAM 的带宽效率（理想 Nyquist 条件下）常用：

- 每个符号携带比特数：
  \[
  k = \log_2(M)
  \]
- 若滚降系数为 \(\alpha\) 的成形滤波，近似频谱效率：
  \[
  \eta \approx \frac{\log_2(M)}{1+\alpha} \; \text{bits/s/Hz}
  \]
- 若课堂未引入 \(\alpha\)，可先给理想上限：
  \[
  \eta \approx \log_2(M)
  \]

因此：
- M=4  → 2 bits/symbol
- M=16 → 4 bits/symbol
- M=64 → 6 bits/symbol

报告中要说明你采用的带宽效率定义（是否考虑滚降系数）。

## 5) 结果讨论建议（可直接用于报告）

1. **星座图**：M 越高，点间距越小，对噪声更敏感。
2. **BER 性能**：同一 Eb/No 下，通常 `BER(64QAM) > BER(16QAM) > BER(4QAM)`。
3. **频谱效率权衡**：高阶 QAM 频谱效率高，但要达到同 BER 需要更高 Eb/No。
4. **工程结论**：根据信道条件动态选择调制阶数（自适应调制思想）。

## 6) 你还需要补充的交付物清单（对照 README）

- [ ] Simulink 总体框图截图（本模型）
- [ ] M=4/16/64 在无噪声与有噪声下的星座图
- [ ] 对应波形图（可用 Time Scope）
- [ ] BER vs Eb/No 三曲线同图
- [ ] 带宽效率计算表格（M=4/16/64）
- [ ] 对性能与权衡的文字分析

---

如果你愿意，我下一步可以继续直接给你 `task2_ber_sweep.m` 的完整可运行版本（含自动出图与保存 png）。


## 7) R2022b 兼容说明

- 已避免依赖偏门模块，优先使用通信系统工具箱中的常规模块。
- 若你本机仍出现某个块路径报错，按脚本报错提示在 Library Browser 搜索该块名字，并把对应路径补到 `add_block_try(...)` 的候选列表即可。
