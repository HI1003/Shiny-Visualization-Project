# STATS125 content-improvement verification

This file preserves the `09a0f90` content stage. Later access and layout changes are recorded in [layout_verification.md](layout_verification.md).

Date 2026-10-31, Pacific/Auckland. Implementation baseline `7852cc1`. The [teaching review](../TEACHING_REVIEW_STATS125.md) and [course/question evidence](teaching_scope_2026_10_31.json) supplied the course basis. Course materials were not all reread in this round.

## Implemented at this stage

- Sidebar routes defaulted to **STATS125 Core**, with **Optional STATS210 preview** and **Further exploration**. The 42 questions comprised 30 core, 8 preview and 4 further, with independent navigation/completion counts. Game scoring remained separate.
- Original Joint 10 / Conditional 13 / Expectation 9 questions and answer fields were retained. Ten additions, O01, J11–13, C14–17 and E10–11, covered CDF endpoints, frequencies to PMFs, marginals, independence, conditioning directions, zero marginals, discrete parameters, second moments/variance and total expectation. Each had two hints and a solution. Every field had to be correct, and repeated success counted once.
- The table modules could explicitly load cards, 20 fictional observations and zero-marginal examples, synchronised within the session. Question reference tables were fixed, and navigation preserved the interactive table. Source and custom-variable guidance was added.
- Fifteen Overview presets loaded the matching model, parameters, preset and x. Poisson λ reached 30, Normal μ ranged over [-100,100], and Uniform b reached 200, covering question values 12/24, 50/65 and 100/140. Bernoulli defaulted to p=.4, matching the added CDF question.
- Core plots offered seven discrete models. Preview offered Uniform, Exponential and Normal with density/area, waiting-time and location/scale tasks and collapsed formulas. Remaining continuous models stayed in further exploration.
- Home added prerequisites and a notation/parameter-unit glossary. Conditional/total expectation, E[g(X)] and variance remained core.

## Verification

| Group | Result | Evidence |
|---|---|---|
| Original Joint interactions | 102/102 | [content_r1_04_ui.json](content_r1_04_ui.json) |
| Independent rational table/answer/equation checks | 10/10 | [content_r1_04_math.json](content_r1_04_math.json) |
| R1-05 conditional tables | 11/11 | [content_r1_05.json](content_r1_05.json) |
| R1-06 validation, normalisation and synchronisation | 124/124 | [content_r1_06.json](content_r1_06.json) |
| Remaining original modules, models, game and two sessions | 300/300 | [content_remaining.json](content_remaining.json) |
| Paths, new questions, presets and app progress | 158/158 | [content_learning_paths.json](content_learning_paths.json) |
| Chrome/Shiny pages | 22/22 | [content_browser.json](content_browser.json) |
| Images | 13/13 | [content_assets.json](content_assets.json) |

Module checks totalled **695/695**, comprising the original 537 and 158 new checks. Mathematics, browser and asset checks are separately listed. Original bank checks explicitly selected internal `legacy` to retain question order/assertions. New checks inspected the real default 30 core and optional 8/4 collections. Students could not choose legacy. All original 32 answer fields matched `7852cc1`.

New tests submitted independently listed correct answers to actual modules. Coverage included fractions, missing/wrong fields, controlled names, three feedback levels, navigation boundaries, path-specific progress, repeated success, explicit table loading, invalid conditions, plot CDFs/ranges and app totals. Separate pages/sessions retained independent progress. A transient navigation-index error during route switching was fixed and covered in all three table modules.

The browser loaded C04 as Poisson(12) at x=10 with F(10)=0.347229, Sunny with λ=24, Normal(65,sd=3) and Uniform(0,140). At Uniform x=50, CDF=.357143 and the question tail probability is 9/14. Screenshots at 1266×900 and 900×900 were visually checked. Stable narrow layouts had no page-wide overflow or visible Shiny output errors. Plotly Canvas performance messages were observed.

Screenshots show [core questions](content_core.png), [preview](content_preview.png) and [900px](content_preview_900.png), all from the local app.

## Reproduction

Run `./review/scripts/run_regression.ps1 -ReportPrefix content` from the repository root with R, project dependencies and Python. Historical comparison needs commit `7852cc1`. Helpers load from main.R, independently of review files and G: course materials.

After starting the app, run `./review/scripts/test_assets.ps1 -ReportPath review/evidence/content_assets.json`, setting `-BaseUrl` when needed. Playwright CLI can run `review/scripts/check_content_browser.js` against the open local app. Prepare ignored `output/playwright/` for temporary screenshots. This round used an independent Chrome profile and port 7130.

## Scope and delivery at that stage

Progress was session-local. Formulas, assumptions and support were explained, with free-text reasoning left for human review. C16–17 added parameter checks while older name questions retained their rules. T125-06 added the learning-order guidance without rearranging the story or default 3D layout.

Teacher/student acceptance, official exam scope, complete course coverage and production concurrency were separate follow-up matters. The local changes were unpushed and undeployed. Course files, extracted text, dependencies, browser state and logs stayed local, and historical evidence was retained.
