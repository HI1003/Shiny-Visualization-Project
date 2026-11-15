# Practice access, clipping and page-layout improvements

This record describes 2026-10-31. The subsequent 2026-11-01 revision prioritised concepts and visualisation, with [its own verification](concept_first_verification.md).

Date 2026-10-31, Pacific/Auckland. Baseline `09a0f90`. The user approved practice-access improvements and reported clipped text and inefficient use of space. Course paths, question counts and answer requirements were retained.

## Reproduction and fixes

| ID | Confirmed issue | Change |
|---|---|---|
| U1-01 | At 1266px, Joint's theory column was 213px while content needed about 420px | Three table modules gained expandable full-width theory. The same viewport provided about 969px, with local scrolling for long formulas. |
| U1-02 | Practice followed plots and was difficult to find | Home gained core/Joint practice buttons and modules gained section links. Practice entered the primary view, with focus moved to the anchor. |
| U1-03 | An empty four-column Joint placeholder pushed the table right and clipped marginals | The empty column was removed, using the available table width. The default table fit all four tested widths. |
| U1-04 | Fixed narrow theory/editor columns and plot order wasted space | Wide layouts used practice/table columns, narrow layouts stacked them, inputs used a compact grid, 2D came first and 3D resized when expanded. |
| U1-05 | Long options touched arrows, help crowded buttons and the collapsed sidebar left insufficient room | Options wrapped with arrow space, help used a separate line and the path control hid while the sidebar was collapsed. |
| U1-06 | Math typeset in hidden tabs acquired zero width and overlapped later text | Re-typeset after visibility/width/content changes and repair visible zero-width formulas. Bernoulli's inline formula recovered from 0 to about 152.7px, also visually checked in dark mode. |
| U1-07 | Overview mixed long explanations with narrow controls and plots temporarily exceeded their containers | Separate parameter and plot areas, full-width collapsible explanations/formulas and responsive plot stacking. Existing plots remain contained during redraw. |

Screenshots show [before](layout_before.png), [Joint](layout_joint_1266.png), [390px](layout_joint_390.png), [full-width theory](layout_joint_theory.png), [Conditional](layout_conditional_1266.png), [Expectation](layout_expectation_1266.png), [Overview](layout_overview_1266.png) and [dark/inline formulas](layout_dark.png), all from the local app.

## Verification

| Group | Result | Evidence |
|---|---|---|
| Original Joint interactions | 102/102 | [layout_r1_04_ui.json](layout_r1_04_ui.json) |
| Independent rational mathematics | 10/10 | [layout_r1_04_math.json](layout_r1_04_math.json) |
| R1-05 conditional tables | 11/11 | [layout_r1_05.json](layout_r1_05.json) |
| R1-06 validation, normalisation and shared table | 124/124 | [layout_r1_06.json](layout_r1_06.json) |
| Other models, questions, game and sessions | 300/300 | [layout_remaining.json](layout_remaining.json) |
| Paths, new questions and progress | 158/158 | [layout_learning_paths.json](layout_learning_paths.json) |
| Chrome layout, entry, formulas and themes | 77/77 | [layout_browser.json](layout_browser.json) |
| Student answer/path/parameter flows | 22/22 | [layout_content_browser.json](layout_content_browser.json) |
| Image HTTP | 13/13 | [layout_images.json](layout_images.json) |
| CSS/JS HTTP and SHA-256 matching | 2/2 | [layout_static_assets.json](layout_static_assets.json) |

Module checks remained **695/695**. Mathematics, browser and assets are separately listed. R parsing and Git whitespace checks passed. Reported R fingerprints matched this version. Original 32 answers matched `7852cc1`, and 30/8/4 paths/game scoring were retained.

Layout coverage used Joint, Conditional, Expectation and Overview at 1600/1266/900/390px widths and 900px height. Checks covered page overflow, overlapping controls, ordinary text wrapping, table bounds, wide columns/narrow stacking, Home/module links, focus, theory expansion, two 3D redraws, sidebar collapse/expansion, dark text and formula widths. Screenshots were visually reviewed. Long narrow-screen formulas retained local scrolling.

The 22 student-flow checks covered wrong/missing fields, fractions, table loading, independent 30/8/4 progress, C04 → Poisson(12) at x=10, Poisson(24), Normal(65,sd=3), Uniform(0,140) and independent tabs. Measurements waited for stable layouts. No visible Shiny output error remained. The game retained its existing automated regression, without a new manual seven-chapter run.

## Reproduction and delivery at that stage

Run `./review/scripts/run_regression.ps1 -ReportPrefix layout`, then assets against the running app using `./review/scripts/test_assets.ps1 -ReportPath review/evidence/layout_images.json` and the appropriate `-BaseUrl`. Standard entry points are Start-Shiny.R and Project_PPeek1ng/app.R. The preview stayed on [7130](http://127.0.0.1:7130/), with the earlier 7125 process untouched.

An independent Chrome profile and Playwright CLI ran `check_layout_browser.js` and `check_content_browser.js`. Temporary output stayed in ignored `output/playwright/`, with selected screenshots/JSON copied to review/evidence. Earlier evidence was preserved.

Audit, teaching, handover and work-log records were updated in an independent local commit, unpushed and undeployed at that stage. Course materials, dependencies, logs and browser caches were excluded. Coverage was the local Chrome environment and stated widths. Human time was recorded separately from the automatic tool window and 15-hour budget.
