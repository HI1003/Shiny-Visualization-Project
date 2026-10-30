# 浏览器复现记录

2026-10-21，Windows Chrome，本机 `http://127.0.0.1:7125/`，`Start-Shiny.R --no-browser` 启动。浏览器检查发生在 15:18 NZDT 之后；工作窗口见 WORKLOG。应用基线 `0f609de`。本轮使用真实页面输入/点击、可见 DOM 及屏幕目视检查，没有通过浏览器脚本修改 Shiny 内部状态。

| 检查 | 操作 | 实际观察 | 结果 |
|---|---|---|---|
| B01 Home/导航 | 打开应用，进入各模块 | Home、Overview、Game、Joint、Conditional、Expectation 均可进入 | 入口冒烟通过 |
| B02 默认条件表 | 首次进入 Conditional，保持默认 f(Y\|X=0) | 两项概率 .92157、.92157；合计 1.84313 | R1-05 已复现 |
| B03 错误名称 | Conditional Q1 输入 Negative Binomial，待输入更新后 Submit | 反馈元素为 `alert alert-success`，显示 Binomial 的解答 | R1-03 已复现 |
| B04 正确 Poisson 概率 | Next 至 Conditional Q4，输入 .347229417554172，待输入更新后 Submit | warning 提示要求对 Poisson(12) 的 0 至 10 求和 | R1-01 Q4 已复现 |
| B05 精确分数 | Expectation Next 至 Q4，输入 10000/3，待输入更新后 Submit | warning 提示计算二阶矩 | R1-02 已复现 |
| B06 Joint 默认与题库 | 进入 Joint，读取练习 Q1 表 | 显示 9 个给定分数；用独立脚本求和为 17/24 | R1-04 的表数据可见，其他题由源码复算 |
| B07 负概率 | Joint 四行改为 -1,1,1,1，待输入更新后 Generate | 未拦截，表中出现负项，仍声明总和为 1；单元格保留原输入，边际使用归一化结果 | R1-06 已复现 |
| B08 Overview | 展开 Probability→Overview，观察 Bernoulli，再选 Geometric，随后切 Continuous | PMF/CDF、PDF/CDF 均出现；几何说明为失败次数；连续模式帮助文字仍称 P(X=x) | 入口通过；R1-07 约定核对；R1-10 提示问题 |
| B09 Game 第一章 | Immediate Response→选 Poisson→Determine | Correct，出现模型解释与 NEXT | 第一章正向流程通过 |
| B10 Game 第二章 | NEXT→Discrete Uniform→Determine | Correct；解释含无情报即等概率、DU 重复抽取成功率不恒定的表述 | R1-11 已复现 |
| B11 Conditional 布局 | 约 1521px 宽默认浏览器页面，查看 Probability Table | 条件选择器覆盖联合表右侧；截图在会话中目视核对 | R1-10 已复现，未存浏览器截图文件 |
| B12 恢复测试数据 | Joint→Uniform→确认四项 .25000→Generate | 恢复为合法均匀表 | 测试后的状态清理 |

注意 Shiny 为异步应用：输入更新、Submit 与反馈更新之间需要等待可见结果。工具首次点击后的即时快照可能仍显示上一状态，本记录以随后确认的页面/反馈为准。B03 第一次即时提交曾显示提示，再次提交后确认 success；不能用尚未更新的快照声称通过或失败。

浏览器可见反馈不是全部数学证据。Q10 Normal、Joint Q2–Q10、p=1 端点、双值答案和零总质量等未全部经浏览器逐一操作，具体证据等级见 ISSUES。未进行移动端、完整可访问性、多用户并发或部署环境验收。
