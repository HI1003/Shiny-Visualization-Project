# 模块审查与教学复核

2026-11-01 用户反馈后的当前定位：**知识点回顾 → 图表可视化理解 → 可选自测**。首页先进入概念回顾，四模块均先展示知识要点与观察提示；练习移至末尾并默认收起，侧栏进度也收起。现有 42 题保留：新增 10 题明确为原创自测，原项目 32 题的真题来源未逐题核实，本轮没有新增历年真题。当前本地改版及 65/65 新浏览器检查、695/695 模块与 22/22 可选练习流程见 [最新验证](evidence/concept_first_verification.md)；本轮尚未推送。

2026-10-31 教学定位：**服务当前 STATS125 学生，少量内容为后续 STATS210 作可选铺垫。** [教学复核及实施](TEACHING_REVIEW_STATS125.md) 已落实默认核心路径，保留原 32 题、增加 10 道核心练习。实际为 **30 核心 / 8 可选预习 / 4 可选拓展**，各自筛题和计数；条件期望、全期望、离散 E[g(X)] 和方差保留为核心。图形预设可从题目载入，匹配参数和选中的 x。最新结果与限制见 [内容改进验证记录](evidence/content_verification.md)。

后续用户体验改进已完成练习入口、文字/公式遮挡和页面布局调整，见 [最新布局验证记录](evidence/layout_verification.md)。首页按钮及模块顶部入口可直达练习；宽屏练习/表格并排，窄屏堆叠，理论全宽展开，3D 默认折叠。695/695 模块、77/77 布局、22/22 学生流程通过；本轮结果另存 layout_*，原证据保留。

此前四次修复已同步 GitHub，基线为 `eabd184`；之后的教学复核 `7852cc1`、核心内容改进 `09a0f90`、页面布局改进 `c534e81` 也已于 2026-10-31 同步。推送后的内容提交与远端 main 一致；同步检查及记录见 [工作日志](WORKLOG.md)。以下首轮和 2026-10-30 数值验证保留为历史记录。教师/学生使用验收待进行，尚未部署。

审查日期：2026-10-21（Pacific/Auckland）。代码基线：`0f609deed5caac75f55542ead1a0b4cd808f4f52`。

首轮审查发现 **11 项已确认问题（8 项 P1、3 项 P2）**，另有会话隔离等待验证事项。**2026-10-30：首轮 11 项全部已修复并验证，另修复会话隔离、模型前提、边界、重启、图片和主题等 7 组问题**。此结果不表示应用已通过整体验收。

2026-10-30 历史结果见 [全量验证记录](evidence/final_verification.md)：R1-04 102/102、R1-05 11/11、R1-06 124/124、本轮 300/300，以及独立有理数核算 10/10、图片资源 13/13。覆盖以各项证据为准，不是所有输入组合或部署验收。

当前复测从仓库根目录运行 `./review/scripts/run_regression.ps1`；新增分层检查已纳入。默认写入 `final_*.json`，使用 `-ReportPrefix content` 可另存本轮结果。应用启动后运行 `./review/scripts/test_assets.ps1`，可用 `-BaseUrl` 与 `-ReportPath` 指定服务/输出。直接调用模块需先加载 `pmf_helpers.R`、`learning_content.R`、`learning_practice.R`；同一学生会话显式传入同一个 `new_pmf_state()`。旧题库专项测试显式使用内部 `legacy` 路径保持原 32 题断言，新增测试另外核验真实应用默认核心；学生界面不能选择 `legacy`。

R1-04 的 [验证记录](evidence/r1_04_verification.md) 包含 10/10 题有理数复核、102/102 真实练习交互检查，以及 R1-05 11/11、R1-06 124/124 的重跑结果。复现需先运行 `Rscript --vanilla review/scripts/test_r1_04.R`，再运行 `python review/scripts/test_r1_04_math.py`。

R1-05 的 [验证记录](evidence/r1_05_verification.md) 包含修复前后对比、11 个真实模块输出案例和浏览器证据。运行当前回归检查：`Rscript --vanilla review/scripts/test_r1_05.R`。首轮 `round1_*` 证据保持原样；首轮脚本中的 `actual_scalar_ifelse`、`invalid_mass_normalization` 是旧表达式复现，修复后状态以专项回归为准。

R1-06 的 [验证记录](evidence/r1_06_verification.md) 包含三模块输入校验、归一化、草稿/结果同步及浏览器证据：124/124 通过；[R1-05 本次重跑](evidence/r1_05_after_r1_06.json) 为 11/11。独立检查：`Rscript --vanilla review/scripts/test_r1_06.R`。直接测试单个模块时需先加载 `modules/pmf_helpers.R`；正常启动由 `main.R` 加载。

| 记录 | 用途 |
|---|---|
| [COURSE_MAP.md](COURSE_MAP.md) | 本地课程来源、章节页码、模块对应关系 |
| [TEACHING_REVIEW_STATS125.md](TEACHING_REVIEW_STATS125.md) | 125 主线、逐题分层、教学缺口、可直接实施的核心练习与先修说明 |
| [ISSUES.md](ISSUES.md) | 问题编号、复现、预期、证据、修复建议和验收条件 |
| [WORKLOG.md](WORKLOG.md) | 本轮工作、时间口径和后续工时记录模板 |
| [HANDOVER.md](HANDOVER.md) | 修复顺序、范围边界和待确认事项 |
| [浏览器记录](evidence/round1_browser.md) | 人机交互复现及覆盖限制 |
| [数值结果](evidence/round1_numeric.json)、[联合题库结果](evidence/round1_joint.json) | 可复算证据 |

## 首轮覆盖（2026-10-21 历史范围）

| 模块 | 已检查 | 本轮深度与限制 |
|---|---|---|
| Home | 导航、学习顺序、参数说明 | 未做完整无障碍审查 |
| Probability Overview | 离散/连续入口、默认 Bernoulli、几何分布说明、连续 Uniform；源码中 PMF/PDF/CDF 实现 | 7 种离散分布和 8 种连续分布未逐一完成全参数浏览器回归；几何/负二项 p=1 已执行源码表达式验证 |
| Game: Discrete | 开始、第一章 Poisson 和第二章 DU 的选择、成功反馈及解释 | 7 章中前 2 章实际操作，后 5 章尚待浏览器回归 |
| Joint | 默认表、负输入、Generate、Uniform、题库输入与导航；10 题独立复算 | 题库全部表格/数值已核对，未逐题点击全部提示层级 |
| Conditional | 默认条件表、错误名称提交、第 4 题提交与反馈；13 题题干及答案结构 | 6 道数值题已复算；7 道分布名称题检查类型与参数，完整文本接受规则仍需改进 |
| Expectation | 默认期望输出、第 4 题精确分数提交；9 题复算与输入结构 | 第 8 题要求两个数但只检查一个；未完成全部交互组合回归 |

课程阅读采用两本主课程手册的相关章节定位与核对，**没有逐份阅读下载目录内所有历史版本、作业或试卷**。STATS210 当前下载目录中的完整手册是 2024 年版本，应保留版本标记。课程原 PDF、抽取文本和页面图像留在 `G:\STATS` 或被忽略的 `.local/course-review/`，不加入 Git。

## 复测与历史证据

完整回归：

```powershell
./review/scripts/run_regression.ps1
```

默认使用本机 R 4.6.1 与 Inkscape 自带 Python，可用 `-RscriptPath`、`-PythonPath` 指定其他安装位置。脚本依赖项目现有 R 包和 Python 标准库，不需要课程 PDF。`test_assets.ps1` 需先运行 `Rscript Start-Shiny.R --no-browser`。

`round1_audit.R` / `round1_joint_audit.py` 保留用于首轮基线 `0f609de` 的复现，包含旧错误表达式。它们不是当前回归入口；不要在当前代码上运行并覆盖 `round1_*` 历史结果。当前模块的共享判题函数已移至 `pmf_helpers.R`，应使用真实模块回归脚本。
