# Concept review and visual exploration first

Date 2026-11-01, Pacific/Auckland. Baseline `5063d1d`. The user requested concept review before visual exploration, with optional practice because students already have quizzes/assignments. Identified past-exam questions might be more appealing. This was a design direction based on the user's feedback.

## Page sequence at this stage

1. **Review concepts.** Four learning modules initially show short key ideas and expandable full definitions/formulas, retaining STATS125 core and optional STATS210 topics.
2. **Explore visually.** Observation prompts accompany existing tables, parameters, 2D/3D views, condition selectors and expectations. These features are available independently of questions.
3. **Optional self-checks.** The 42 questions remained, at the bottom and initially collapsed. Sidebar progress also collapsed. Home buttons first entered review. Historical 30/8/4 groups were optional practice counts.

Review topics were PMF/CDF/model definitions, joint/marginal distributions and independence, conditional distributions with positive denominators, and weighted/total expectation, based on C125 Chapters 5–8 and the [teaching review](../TEACHING_REVIEW_STATS125.md). Optional continuous topics explained density/area, zero point probability, CDFs and parameters.

## Exercise provenance at that stage

- The ten added questions were labelled original self-checks created for this tool.
- The original 32 project questions were labelled supplementary exercises with unverified exam provenance. Their original authorship was not inferred.
- This round added no past-exam extracts. Future selections would need year/paper/question verification, source/adaptation labels and reference solutions. A small set directly related to visualisation was proposed, with full-course/exam PDF publication outside that stage's scope.

## Verification

| Group | Result | Evidence |
|---|---|---|
| Original Joint interactions | 102/102 | [concept_r1_04_ui.json](concept_r1_04_ui.json) |
| Joint independent mathematics | 10/10 | [concept_r1_04_math.json](concept_r1_04_math.json) |
| Conditional table / PMF input and synchronisation | 11/11, 124/124 | [R1-05](concept_r1_05.json), [R1-06](concept_r1_06.json) |
| Other modules and paths | 300/300, 158/158 | [Modules](concept_remaining.json), [paths](concept_learning_paths.json) |
| Actual review → plot → optional practice pages | 65/65 | [Browser](concept_browser.json) |
| Full flow after explicitly expanding practice | 22/22 | [Optional practice](concept_optional_browser.json) |
| Images / CSS and JS | 13/13, 2/2 | [Images](concept_images.json), [resources](concept_static_assets.json) |

Module totals remained 695/695, with original numerical/answer assertions and the 32-question answer baseline. The 65 new browser checks covered module order, collapsed questions/progress, review/plot navigation, provenance labels, question-free exploration and text/table boundaries at 1600/1266/900/390px. The 22 practice checks explicitly expanded the optional area and retained scoring, parameters and isolation assertions.

Visually checked screenshots show [Overview](concept_overview_1266.png), [Joint](concept_joint_1266.png), [Conditional](concept_conditional_1266.png), [Expectation](concept_expectation_1266.png), [phone Overview](concept_overview_390.png) and [phone Joint](concept_joint_390.png).

## Follow-up and reproduction

Review whether the concepts are clear, parameter changes/plots support understanding and tables correspond easily to plots. Teachers were to confirm a small selection of exam questions and their sources.

Run `./review/scripts/run_regression.ps1 -ReportPrefix concept`. Use Playwright CLI `run-code --filename review/scripts/check_concept_browser.js` with the local app open. Optional-practice regression uses `check_content_browser.js`. Older `layout_*` records describe the previous practice-first order.

The local revision was unpushed and undeployed, with preview on 7130. Original question banks, source indexes and evidence were retained. Course PDFs, dependencies, extracted text, browser profiles and logs remained excluded. Automated runtime was recorded separately from the 15-hour human-work budget.
