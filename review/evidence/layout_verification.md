# 练习入口、遮挡与页面布局改进

本文件记录 2026-10-31 的历史改版。2026-11-01 用户反馈后已将主线改为知识回顾与可视化优先、练习可选；当前页面顺序及验证见 [concept_first_verification.md](concept_first_verification.md)。

日期：2026-10-31（Pacific/Auckland）。基线：`09a0f90`。本轮落实用户同意的练习入口改进，并处理其提出的文字遮挡、布局和空间利用问题。原课程分层、题量及判题要求保留。

## 复现与修复

| ID | 已确认的问题 | 当前处理 |
|---|---|---|
| U1-01 | 1266px 窗口中，Joint 理论栏实际宽 213px，内容需约 420px；长公式被限制在窄栏 | 三个表格模块的理论移至可展开的全宽区域；同视口理论区域约 969px；长公式在小窗口保留局部横向滚动 |
| U1-02 | 练习在图形之后，需下滚寻找；用户未能找到新增题 | 首页增加核心练习/联合表练习按钮；各模块顶部增加练习、表格、理论、图形入口；练习进入主区域首屏，锚点移动焦点 |
| U1-03 | Joint 结果区有空的 4 列占位，把表格推向右侧；放入较窄区域后边际列超出可见边缘 | 移除空列，完整使用表格区域宽度；四种测试宽度的默认表均完整可见 |
| U1-04 | 固定的理论/编辑器窄列和图形顺序造成空间分配失衡 | 宽屏以练习/交互表格双列排列，窄屏上下排列；输入行使用紧凑网格；2D 视图优先，3D 默认折叠且展开后重新适配尺寸 |
| U1-05 | 长选项文字接近下拉箭头；说明文字与按钮挤在同一行；收起侧栏后学习路径控件空间不足 | 选项换行并预留箭头空间，说明单独成行；收起侧栏时隐藏学习路径控件，展开可恢复 |
| U1-06 | 公式在隐藏页中排版后，内联公式实际宽度变成 0，切回页面时与后续文字重叠 | 页面显示、宽度变化和展开内容时重排公式；观察动态内容并修复可见的零宽公式。实测 Bernoulli 公式由 0 恢复为约 152.7px，深色截图复核未再重叠 |
| U1-07 | Overview 长解释与参数混放，窄列拥挤，图形在宽度变化时短暂越界 | 参数与图形分区，说明/公式集中到全宽折叠区域；图形根据实际可用宽度并排或堆叠；旧图像等待重绘期间也限制在容器内 |

截图：[原布局](layout_before.png)、[新版 Joint](layout_joint_1266.png)、[390px](layout_joint_390.png)、[全宽理论](layout_joint_theory.png)、[Conditional](layout_conditional_1266.png)、[Expectation](layout_expectation_1266.png)、[Overview](layout_overview_1266.png)、[深色及内联公式](layout_dark.png)。只包含本地应用，不包含课程平台、PDF 或学生记录。

## 验证

| 验证组 | 结果 | 证据 |
|---|---|---|
| 原 Joint 题库交互 | 102/102 | [layout_r1_04_ui.json](layout_r1_04_ui.json) |
| Joint 独立有理数核算 | 10/10 | [layout_r1_04_math.json](layout_r1_04_math.json) |
| R1-05 条件概率表 | 11/11 | [layout_r1_05.json](layout_r1_05.json) |
| R1-06 输入校验、归一化与共享表 | 124/124 | [layout_r1_06.json](layout_r1_06.json) |
| 其他分布、练习、游戏与会话检查 | 300/300 | [layout_remaining.json](layout_remaining.json) |
| 核心分层、新题与进度 | 158/158 | [layout_learning_paths.json](layout_learning_paths.json) |
| 实际 Chrome 布局、入口、公式和主题 | 77/77 | [layout_browser.json](layout_browser.json) |
| 实际学生答题与分层/参数流程 | 22/22 | [layout_content_browser.json](layout_content_browser.json) |
| 图片 HTTP | 13/13 | [layout_images.json](layout_images.json) |
| 布局 CSS/JS HTTP 与文件 SHA-256 一致 | 2/2 | [layout_static_assets.json](layout_static_assets.json) |

模块检查合计仍为 **695/695**，独立数学、浏览器与资源另列。R 解析及 Git 空白检查通过；报告的 R 源码哈希与当前文件核对一致；原 32 题答案与 `7852cc1` 比较保持一致，30/8/4 分层与游戏评分规则保留。

布局检查覆盖 Joint、Conditional、Expectation 与 Overview，分别在 1600、1266、900、390px 宽、900px 高窗口验证。检查整页横向溢出、面板/输入重叠、普通文字换行及默认表边界；宽屏两列，小窗口堆叠。另验证首页两个按钮及模块跳转、理论展开、两个 3D 图展开重绘、侧栏收起/展开、深色正文对比和公式实际宽度。截图经目视复核；窄屏长公式可能需要在所在区域横向滚动，不以截断来隐藏超长内容。

22 项学生流程继续检查错一项不计分、分数答案、显式载入题表、30/8/4 独立进度、C04→Poisson(12) 且选中 x=10、Poisson(24)、Normal(65,sd=3)、Uniform(0,140)、两个标签页独立等。窗口变化时先等待布局稳定再记录尺寸，保留原断言。最后无可见 Shiny 输出错误；本轮未重新手动走完游戏 7 章，游戏模块原回归保留。

## 复现与交付

仓库根目录运行 `./review/scripts/run_regression.ps1 -ReportPrefix layout`。启动应用后运行 `./review/scripts/test_assets.ps1 -ReportPath review/evidence/layout_images.json`，需要时传实际 `-BaseUrl`。标准入口仍为 `Start-Shiny.R` / `Project_PPeek1ng/app.R`；本轮保留新版预览 [7130](http://127.0.0.1:7130/)，此前 7125 进程未干预。

浏览器使用独立 Chrome 配置，经 Playwright CLI 打开本地应用，再执行 `run-code --filename review/scripts/check_layout_browser.js` 与 `run-code --filename review/scripts/check_content_browser.js`；临时输出目录为忽略的 `output/playwright/`。最终选取截图/JSON另存到 review/evidence，旧 content_* 与更早证据保留。

已更新审查、教学复核、交接及工作日志，并保存为独立本地提交。未推送、未部署；课程资料、依赖、日志和浏览器缓存排除。人工工时单列，不把自动工具窗口计入 15 小时。测试覆盖本机 Chrome 与上述宽度，未声称覆盖所有设备、浏览器缩放、屏幕阅读器或正式课堂验收。
