# 使用说明（基于当前仓库 README）

当前 `README.md` 只有标题、简短描述和一张图片，没有可直接解析的文字任务细节。

已提供脚本：`build_homework_model.m`

## 1) 自动搭建模型
在 MATLAB 命令行执行：

```matlab
modelName = build_homework_model();
```

会生成 `hw_autobuild_model.slx`，结构为：

`Step -> Sum -> PID -> Plant -> Scope`，并带单位负反馈与 `To Workspace` 输出。

## 2) 按作业题目替换关键参数
根据你题目图片中的要求，重点改这几处：

1. `Step` 幅值、阶跃时刻。
2. `Plant` 的传递函数分子/分母。
3. `PID` 参数（P/I/D）。
4. 仿真时间与求解器。

## 3) 典型作业完成流程

1. **还原题目模型结构**：如果图片里不是 PID+Plant，就把脚本中的模块换成题目对应模块（比如积分器、增益、求和、状态空间、开关等）。
2. **设置参数**：把所有给定常数抄入模块参数。
3. **运行仿真**：检查波形是否与题目示意一致。
4. **做指标计算**：从 `y_out` 计算上升时间、超调量、稳态误差等。
5. **参数整定/对比实验**：按题目要求做多组参数、截图和表格。
6. **整理报告**：包含模型图、关键参数、输出曲线、指标表、结论。

## 4) 结果导出建议

- 在 Scope 中保存图像（PNG）用于报告。
- 使用 `y_out` 在 MATLAB 中自动算指标，例如：

```matlab
data = y_out;
t = data.time;
y = data.signals.values;
info = stepinfo(y, t, 1);
ess = abs(1 - y(end));
```

