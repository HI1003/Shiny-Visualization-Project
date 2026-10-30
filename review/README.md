# 第一轮模块审查

审查日期：2026-10-21（Pacific/Auckland）。代码基线：`0f609deed5caac75f55542ead1a0b4cd808f4f52`。

本轮已完成初步审查，应用代码尚未修改。结果为 **11 项已确认问题（8 项 P1、3 项 P2）**，另有会话隔离等待验证事项。此结果不表示应用已通过验收。

| 记录 | 用途 |
|---|---|
| [COURSE_MAP.md](COURSE_MAP.md) | 本地课程来源、章节页码、模块对应关系 |
| [ISSUES.md](ISSUES.md) | 问题编号、复现、预期、证据、修复建议和验收条件 |
| [WORKLOG.md](WORKLOG.md) | 本轮工作、时间口径和后续工时记录模板 |
| [HANDOVER.md](HANDOVER.md) | 修复顺序、范围边界和待确认事项 |
| [浏览器记录](evidence/round1_browser.md) | 人机交互复现及覆盖限制 |
| [数值结果](evidence/round1_numeric.json)、[联合题库结果](evidence/round1_joint.json) | 可复算证据 |

## 本轮覆盖

| 模块 | 已检查 | 本轮深度与限制 |
|---|---|---|
| Home | 导航、学习顺序、参数说明 | 未做完整无障碍审查 |
| Probability Overview | 离散/连续入口、默认 Bernoulli、几何分布说明、连续 Uniform；源码中 PMF/PDF/CDF 实现 | 7 种离散分布和 8 种连续分布未逐一完成全参数浏览器回归；几何/负二项 p=1 已执行源码表达式验证 |
| Game: Discrete | 开始、第一章 Poisson 和第二章 DU 的选择、成功反馈及解释 | 7 章中前 2 章实际操作，后 5 章尚待浏览器回归 |
| Joint | 默认表、负输入、Generate、Uniform、题库输入与导航；10 题独立复算 | 题库全部表格/数值已核对，未逐题点击全部提示层级 |
| Conditional | 默认条件表、错误名称提交、第 4 题提交与反馈；13 题题干及答案结构 | 6 道数值题已复算；7 道分布名称题检查类型与参数，完整文本接受规则仍需改进 |
| Expectation | 默认期望输出、第 4 题精确分数提交；9 题复算与输入结构 | 第 8 题要求两个数但只检查一个；未完成全部交互组合回归 |

课程阅读采用两本主课程手册的相关章节定位与核对，**没有逐份阅读下载目录内所有历史版本、作业或试卷**。STATS210 当前下载目录中的完整手册是 2024 年版本，应保留版本标记。课程原 PDF、抽取文本和页面图像留在 `G:\STATS` 或被忽略的 `.local/course-review/`，不加入 Git。

## 复算

从仓库根目录依次运行；需要项目已有的 R 依赖与 Python 3 标准库，不需要课程 PDF：

```powershell
Rscript --vanilla review/scripts/round1_audit.R
python review/scripts/round1_joint_audit.py
```

本机 R 路径为 `C:\Users\ghu206\Desktop\WYF\BIB\R\R-4.6.0\bin\x64\Rscript.exe`。Python 本轮使用 `C:\Program Files\Inkscape\bin\python.exe`。

脚本从当前源码的语法树提取题库/判题函数；中间题库 JSON 留在 `.local`。它们是**审查工具**，用于记录缺陷，不是宣称应用通过的测试集。后续修复应另行执行真实模块回归，核对更新后的题干、答案、提示、解答与图形。
