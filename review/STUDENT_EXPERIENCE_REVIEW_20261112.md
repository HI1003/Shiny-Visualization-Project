# Student-task walkthrough on 2026-11-12

**Implementation update on 2026-11-14.** Joint probability encoding and total-expectation weighting were implemented after this review. Joint/Conditional 3D views were removed, plot/table formats aligned, editors collapsed and Overview paths/parameters simplified. See [WORKLOG](WORKLOG.md). The observations and recommendations below describe 12 November.

A real Chromium browser followed distribution selection → concept review → parameter/plot exploration → optional exams, then Joint, Conditional, Expectation and all seven game chapters. Checks covered desktop/tablet/phone widths, light/dark themes and invalid-input recovery. This was an agent walkthrough of student tasks. Teacher/student trials remained pending.

## Findings at that stage

The main route was usable and calculation regression passed. Priorities were directly encoding probability magnitude in graphics and making the relation between conditional and overall means clearer. Additional exercises were lower priority.

## Fixes completed in this round

| ID | Observation | Change and verification |
|---|---|---|
| UX-01 | Joint/Conditional/Expectation exam loading updated data but left the student at the page bottom | Successful loading moves viewport and keyboard focus to the exploration section, checked in all three table modules |
| UX-02 | Changing table examples reset conditioning direction | Direction retained, with an existing Conditional value retained or replaced by a valid new value. Tested using nondefault directions. |
| UX-03 | Determine with no model selected gave no feedback | Selection prompt, unchanged score/chapter, with empty submissions excluded from wrong-attempt counts |
| UX-04 | NEXT sometimes left the new chapter heading out of view | Start/next/back/restart position at the current chapter top. All seven chapters checked. |
| UX-05 | Grey explanations and dark-green success text were difficult to read | Brighter success/reveal/analysis/hint/scoring text, reviewed on rendered pages |
| UX-06 | Expectation calculation and conditional-mean headings remained dark grey in dark mode | Scoped calculation-panel theme inheritance, both headings checked and visually reviewed |

The changes retained calculation and question contents, course scope and the user's existing interface choices.

## Recommendations in priority order

### 1. Encode Joint probability magnitude in the main 2D view

Implemented on 2026-11-13 as a numerical heatmap aligned with the table, fixed 0–1 colour scale, compact labels and narrow-screen font sizing. See that date's work-log entry. The following describes the preceding design.

Identical points at every (x,y) exposed probability only on hover. Changing probabilities left the point appearance unchanged. The optional 3D view used height but was initially collapsed. The recommended main view was a numerical heatmap with a legend. An alternative scatter view would need probability-proportional areas and an area legend. Zero probabilities and absent combinations needed clear interpretation. The table retained exact readings and existing generic examples were sufficient.

### 2. Show weighted conditional means producing the overall mean

Implemented on 2026-11-13 as a linked decomposition table, weighted formula and stacked contribution bar, supporting both directions and zero-weight groups. The 2026-11-14 flow subsequently made multiplication/addition explicit. The following describes the original gap.

The page explained E[g(X)], conditional means and total expectation, but the controls primarily returned E[X], E[Y] and conditional means. Students had to connect each conditional mean × marginal probability and the final sum themselves. The recommendation was a linked decomposition that updates means, weights and the overall result together. Further transformation/variance controls would be needed before describing those as interactive capabilities on Home.

### 3. Reduce initial reading and control load

- Home mixed an introduction, operating guidance, course route and authorship. Shorten the initial student text and retain expandable details and author credits.
- Collapse table editors initially so students first see the example and plots.
- Consider a simple frequency example as the default and cards as another choice. This suggestion was not implemented in this review.
- Keep the seven-chapter game optional. If shortened later, foreground variables, assumptions and reasons for model choice.

### 4. Align paths, optional exams and number presentation

- Preview's three models also appeared in further exploration. Clarify the additional continuous-distribution route while retaining STATS125 as default.
- Four verified question groups were available. Overview's question was fixed rather than changing with every selected distribution. Clarify that it uses its own model or scope it to the matching distribution. Preserve the verified-source requirement.
- Static source solutions still contained long decimals while interactive values used compact display. Any later rounding should use a presentation layer and approximation marks while preserving source values/checking precision. This round left static solutions intact.
- The top ? and sun toggles needed clearer functional names. Home's October 2025 date needed distinction from the revision date at delivery.

## Behaviour needing further confirmation

An immediate post-connect navigation and an unsettled dynamic update each produced a temporary blank region that recovered on revisiting the menu. Stable runs passed. Test scripts were corrected to wait for actual feedback updates. Daily-use Chrome cold starts/rapid navigation remained a delivery follow-up, including consideration of clearer initialisation feedback.

## Actual coverage

- Overview covered seven discrete definitions/formulas/plots/examples, three preview models and each of the eight legacy continuous models, with actual plot selection.
- Joint covered automatic example loading, 2D hover, optional 3D, editing/deletion, Uniform/Normalize/Generate and retained valid state after negative/all-zero input.
- Conditional covered both directions, conditioning values, zero-probability feedback/recovery and shared tables.
- Expectation covered overall/conditional means, both directions, zero-probability handling, retained direction and themes.
- Exams covered four groups' source/adaptation metadata, progressive feedback, answers, count-once progress, table/plot loading and retained module progress. The JSON HTTP path returned 404. Raw question/answer/browser contents were excluded from this report.
- Game covered empty/wrong selection, seven correct answers/explanations, positioning, ending/restart and phone layout. Shared back-button positioning code was covered without counting every chapter's back branch as a separate manual step.
- Main modules/exam sections used 1600/1266/900/390px. Overview additionally used 1440/1024/768/390px. Selected Home/Overview/table/expectation/game/phone/theme screenshots were visually checked.

R results were R1-04 **102/102**, R1-05 **11/11**, R1-06 **124/124**, remaining modules **301/301**, local exams/app **87/87**, display/precision **76/76**, independent mathematics **10/10** and images **13/13**. See the [dated summary and fingerprints](evidence/student_experience_20261112.json). Counts identify checks performed.

Course scope followed the existing [teaching review](TEACHING_REVIEW_STATS125.md) and [mapping](COURSE_MAP.md), without a new page-by-page coursebook review. Teacher/student trials, cross-browser acceptance, complete keyboard/screen-reader review and deployment remained pending.

## Plot-reading update on 2026-11-13

All 15 distributions gained hover/touch readings with linked PMF/PDF and CDF at the same x. Permanent plot annotations and Current Selection were removed, and the heading became Distribution plots. CDF open/closed endpoints remain, with open endpoints excluded from point readings. Continuous plots retain the density explanation. Exploration prompts after definitions were removed throughout the distribution and table modules.

Joint's numerical heatmap and Expectation's decomposition/contributions remain visible for comparisons and calculation relationships. See [interaction evidence](evidence/distribution_hover_20261113.json). Earlier click-selection/path descriptions retain their original dates.

## Historical record/material boundaries

At this stage course PDFs remained on G:, with the private bank, temporary fixtures/logs, browser state and screenshots under ignored folders. This report and public summary excluded question text, answers, original tables and course extracts. The round was uncommitted/unpushed and left the original comparison version intact. Human effort was separately recorded from the automatic runtime and 15-hour budget. The later user clarification removed the timesheet task, and the selected bank/PDF publication was authorised on 2026-11-16.
