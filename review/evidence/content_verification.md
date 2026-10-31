# STATS125 内容改进验证

日期：2026-10-31（Pacific/Auckland）。实现基线：本地 `7852cc1`。课程依据沿用 [教学复核](../TEACHING_REVIEW_STATS125.md) 和 [课程来源/逐题证据](teaching_scope_2026_10_31.json)；本轮没有重新逐份阅读全部课程资料。

## 已实现

- 侧栏默认 **STATS125 Core**；可选 **Optional STATS210 preview** 与 **Further exploration**。42 道题分为 30 核心、8 预习、4 拓展，翻页与完成计数各自独立；游戏沿用自己的分数。
- 保留原 Joint 10 / Conditional 13 / Expectation 9 题及其答案字段。新增 O01、J11–13、C14–17、E10–11 共 10 题，涵盖 CDF 端点、频数转 PMF、边际、独立性、条件方向、零边际、离散模型参数、二阶矩/方差及全期望。每题均有两级提示和解答，多字段必须全部正确，重复答对不额外计数。
- 三模块可显式载入抽牌、20 个虚构观测、零边际三个 PMF 例子，并同步同一会话。题目给出的参考表固定；导航不自动覆盖交互表。新增来源说明和自定义表语境提示。
- Overview 有 15 个图形预设，题目可载入相应场景；载入时同步模型、参数、预设名称与所选 x。λ 控件上限 30，Normal μ 范围 [-100,100]，Uniform b 上限 200，覆盖题中 12/24、50/65、100/140 等数值。Bernoulli 默认 p=.4，与新增 CDF 题一致。
- 核心图形只列 7 种离散分布；可选预习只列 Uniform、Exponential、Normal，给出密度/面积、等待时间及位置/尺度的观察任务，正式公式默认折叠；其余连续模型仍保留在拓展。
- 首页补先修关系和符号/参数单位词表。条件期望、全期望、E[g(X)]、方差继续属于核心。

## 验证结果

| 组别 | 结果 | 证据 |
|---|---|---|
| 原 Joint 题库交互 | 102/102 | [content_r1_04_ui.json](content_r1_04_ui.json) |
| Joint 表/答案/等式独立有理数核算 | 10/10 | [content_r1_04_math.json](content_r1_04_math.json) |
| R1-05 条件概率表 | 11/11 | [content_r1_05.json](content_r1_05.json) |
| R1-06 输入、归一化、三模块同步 | 124/124 | [content_r1_06.json](content_r1_06.json) |
| 其他原模块、分布、游戏、两会话 | 300/300 | [content_remaining.json](content_remaining.json) |
| 新分层、练习、预设与全局进度 | 158/158 | [content_learning_paths.json](content_learning_paths.json) |
| 实际 Chrome / Shiny 页面 | 22/22 | [content_browser.json](content_browser.json) |
| 图片资源 | 13/13 | [content_assets.json](content_assets.json) |

模块检查合计 **695/695**（原有 537，加新增 158）；数学、浏览器及资源分别列出，不混计为独立题数。R1-04 与旧命名/期望题回归显式使用内部 `legacy`，保留全部原断言和原题顺序；新测试独立核对真实应用默认 30 核心及 8/4 可选，学生界面不能选择 legacy。原 32 题答案字段与 `7852cc1` 逐项比较通过。

新增测试使用独立列出的正确答案提交实际模块，不以读取实现中的 expected 字段代替核算。覆盖分数、多字段遗漏/单项错误、受控名称、三级反馈、边界翻页、分层进度保留、重复答对、显式表格载入、无效条件、图形 CDF 数值、范围及真实应用全局计数。覆盖两页/会话互不共享完成数。浏览器发现分层切换瞬间导航索引尚未就绪的错误，已修复并增加三个模块的回归检查。

实际浏览器确认：C04 可打开 Poisson(12) 且选中 x=10，F(10)=0.347229；Sunny 预设 λ=24；Normal(65,sd=3) 与 Uniform(0,140) 参数可用；Uniform x=50 时 CDF=.357143，题目尾概率为 9/14。1266×900 与 900×900 页面已截图目视核对；窄视口等待页面响应完成后无整页横向溢出。最终流程没有可见 Shiny 输出错误。浏览器仅出现 Plotly Canvas 性能提示，未将其当作题目/计算失败。

截图：[核心题](content_core.png)、[可选预习](content_preview.png)、[900px 视口](content_preview_900.png)。只包含本地应用界面，没有课程 PDF、课程平台或学生数据。

## 复现

从仓库根目录运行 `./review/scripts/run_regression.ps1 -ReportPrefix content`。需本机 R、项目依赖及 Python；新测试对比的历史提交为 `7852cc1`，需保留该 Git 历史。新增帮助函数由 main.R 自动加载，不依赖 review/ 或 G 盘课程文件。

资源检查可在启动应用后运行 `./review/scripts/test_assets.ps1 -ReportPath review/evidence/content_assets.json`；服务不在默认 7125 时另传 `-BaseUrl`。浏览器检查通过 Playwright CLI 对当前打开的本地应用执行 `run-code --filename review/scripts/check_content_browser.js`，在忽略的 output/playwright/ 保存临时截图；首次使用需先创建该目录并打开本地应用。本轮使用独立 Chrome 配置和 7130 端口，未操作用户的课程登录。

## 边界与交付

完成数仅在当前会话保留，刷新或新会话重新开始；未实现持久化学生成绩。公式/假设/支持集解释已补，但不自动评阅学生的自由文字论证。C16–17 新增参数考查，旧命名题仍保留原要求。T125-06 仅落实首页游戏顺序建议，未重排游戏故事和 3D 默认布局。

本轮实现不等于教师/学生使用验收、官方考试范围认定、完整课程覆盖或部署并发验收。当前改动保存为独立本地提交，未推送、未部署。课程文件、提取全文、依赖、浏览器配置和临时日志均排除；原证据保留。
