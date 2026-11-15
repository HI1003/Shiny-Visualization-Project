# Project work log

Updated on 2026-11-16. The contract has been signed and the user confirmed that no timesheet is required. Historical budget and time-recording notes below describe the process at their stated dates. The user subsequently authorised publication of the four selected exam groups and their six source PDFs with the English project so recipients can clone the complete app.

The original meeting budget was **15 hours**. Human billable time was to be entered by the user based on actual effort. Automatic review windows were recorded separately.

| Date | Work ID | Work and output | Timing basis | Human billable time at that stage | Status |
|---|---|---|---|---|---|
| 2026-10-21 | REV-01 | Check C125/C210 coursebook versions and chapter locations, render three formula pages and create COURSE_MAP | Preparation partly preceded the first timestamp | Pending user entry | Initial mapping completed |
| 2026-10-21 | REV-02 | Module-entry smoke checks, Joint 10 questions, Conditional six numerical/seven name structures, Expectation nine questions, answer and endpoint checks | First verifiable automatic timestamp 15:18:09 NZDT, including documentation | Pending user entry | First round completed |
| 2026-10-21 | REV-03 | Record 11 issues, browser evidence, scripts/results, fix order and handover | End/window recorded below | Pending user entry | Recorded before fixes |

## Original record principles

- Course materials remained in `G:\STATS`, with extracted caches under ignored `.local/course-review`.
- Records distinguished source findings, independent calculations, browser reproductions and teacher-review items. Unconfirmed risks were separate from the 11 confirmed issues.
- The first review left app source unchanged and was uncommitted, unpushed and undeployed at that stage.
- Automatic runtime did not determine used/remaining human budget.

## Historical work-entry template

| Date | Start/end | Actual human hours | Issue ID | Work/files | Evidence/retest | Commit | Status |
|---|---|---|---|---|---|---|---|
| Pending | Pending | Pending | e.g. R1-05 | Specific changes | Input, expected, actual, pass/fail | Pending commit | Open → changed → verified → teacher accepted |

## Original 15-hour scope plan

The planned allocation was baseline/records 1h, course/module review 3h, content/calculation fixes 5h, usability 2h, regression 2h, delivery 1h and reserve 1h. Confirmed core-bank errors made P1 fixes the priority, with lower-priority visual work to be reduced if necessary.

## First-round verification record

The verifiable automatic window was **15:18:09–15:35:32 NZDT, 17 minutes 23 seconds**, excluding preparation before the first timestamp and final wrap-up.

Both source PDF SHA-256 values matched the download manifest. R/Python audit scripts checked the 10+13+9=32 question structures/calculations. Issue IDs, priority counts, JSON and documentation links were checked. Course caches were ignored, review/ contained no PDFs and app source matched the baseline. R version/locale warnings did not prevent the app from listening or browser use. Deployment acceptance remained separate.

## 2026-10-30, baseline audit-record commit

GIT-01 placed review documents, evidence summaries and calculation scripts in a separate commit and synchronised origin/main. Title `Record first-round course-based module review`, with SHA/status in Git history and remote verification.

Scope comprised review records and source metadata including paths, versions, page counts and fingerprints. App code, course PDFs/text caches and dependencies were outside this commit. The 11 issues retained their then-open status. Human time remained pending at that stage.

## 2026-10-30, R1-05 conditional-table fix

| Work ID | Work | Verification/status | Human time at that stage |
|---|---|---|---|
| FIX-01 | Elementwise normalisation in both directions and undefined zero-marginal feedback | Fixed/verified, teacher review pending, ten other issues open | Pending |
| TEST-01 | Actual module-output test_r1_05.R, before/after JSON and browser screenshots | 0/11→11/11, nine valid table/plot slices, two zero marginals, browser both directions/Y=1/zero Y | Pending |

Changed module_conditional.R and the associated scripts/evidence/status records. See [verification](evidence/r1_05_verification.md). Local commit `Fix R1-05 conditional probability table normalization`, SHA in Git history, unpushed/undeployed at that point.

Automatic window **13:35:45–13:47:07 NZDT, 11 minutes 22 seconds**, including environment/dependency recovery, reproduction, implementation, regression, browser checks and records, excluding final commit wrap-up.

R 4.6.1 at `C:\Program Files\R\R-4.6.1\bin\Rscript.exe` replaced the unavailable 4.6.0 path. Shiny 1.14.0 and four missing dependencies were installed in ignored .R-library/. Reports retain package versions/source MD5. The default four fractions were restored. Course files/caches stayed outside the commit.

## 2026-10-30, R1-06 three-module input validation

| Work ID | Work | Verification/status | Human time at that stage |
|---|---|---|---|
| FIX-02 | Shared PMF parsing/validation/actions from Joint to Conditional/Expectation, synchronised normalised text/values, retained valid results and recovered empty tables/IDs | Fixed/verified, teacher review pending, nine issues remained | Pending |
| TEST-02 | Forty cases per module plus four within-session cases, three negative-input baseline reproductions and browser recovery/synchronisation | **124/124**, including 0/0, tiny negatives, duplicates, empty tables and large weights | Pending |
| RETEST-01 | Original 11 R1-05 cases, adding shared-helper setup only | **11/11**, separately saved r1_05_after_r1_06.json | Pending |

See [R1-06](evidence/r1_06_verification.md). Code included main.R, new pmf_helpers.R and the three table modules. Local title `Fix R1-06 PMF input validation and normalization`, unpushed/undeployed then.

Automatic window **14:06:12–14:27:05 NZDT, 20 minutes 53 seconds**, covering inspection, implementation, baseline reproduction, regression, browser checks and records, excluding final commit work.

Existing R 4.6.1/dependencies and installed xml2 were used, with no new dependency installation. Final module/helper MD5 values were recorded and question/checking logic compared with the baseline. Browser state ended on valid .1,.2,.3,.4. PDFs, downloads, full text and R libraries stayed excluded. Session isolation, bank errors and layout remained follow-ups.

## 2026-10-30, R1-04 Joint bank fix

| Work ID | Work | Verification/status | Human time at that stage |
|---|---|---|---|
| FIX-03 | Make Q1–Q4 legal by changing non-target cells, derive ten tables/answers/hints/solutions from one source, fix Q4–Q8 and clarify Q8/Q10 | Fixed/verified, teacher review pending, eight issues remained | Pending |
| TEST-03 | Independently parse HTML/rational equations, test two hints/solution, fractions/decimals, wrong input, navigation and zero boundary | Mathematics **2/10→10/10**, interaction **92/102→102/102** | Pending |
| RETEST-02 | R1-05/R1-06 reruns and browser Q5/Q8, final reload/Q1 table | **11/11**, **124/124** | Pending |

Scope was Joint bank generation and nonnegative answer checking. Editors/shared PMF and other module code remained outside this patch. See [verification](evidence/r1_04_verification.md). Local title `Fix R1-04 joint probability question bank consistency`, unpushed/undeployed. Previous evidence was retained.

Automatic window **14:32:50–15:01:50 NZDT, 29 minutes**, including inspection, correction, before/after comparison, mathematical/interactive regression, browser and records, excluding later commit work. Existing R/Shiny and Python's standard library were used. Final report MD5 values matched source. Browser screenshots showed local exercises. Course materials/caches/dependencies were excluded and remaining issues/teacher review continued.

## 2026-10-30, remaining confirmed issues

| Work ID | Work | Verification/status | Human time at that stage |
|---|---|---|---|
| FIX-04 | R1-01/02/03/07/08 precision, complete-name matching, shifted Geometric, paired answers/feedback | All first-round issues fixed/verified, teacher review pending | Pending |
| FIX-05 | R1-09/10/11 endpoints, layout, continuous-density wording and DU assumptions | Specified parameters and two viewports passed | Pending |
| FIX-06 | R2-01–R2-07 session isolation, invalid Uniform/singular density, game assumptions/restart, tiny/zero marginals, assets and theme | Seven groups fixed/verified | Pending |
| TEST-04 | Preserve earlier assertions with explicit session state, add module checks and regression entry | R1-04 102/102, R1-05 11/11, R1-06 124/124, remaining 300/300, independent 10/10, assets 13/13 | Pending |
| UI-04 | Numerical/pair feedback, independent tabs, all seven chapters/21 points/restart, 1266/900 layouts, assets and theme | Separate final_* records/screenshots | Pending |

See [final verification](evidence/final_verification.md). Course/scenario acceptance and broader parameter/device/accessibility/production coverage remained separate. Local title `Fix remaining course audit issues and session isolation`, unpushed/undeployed. The nested archive remained unchanged then, with current work in the source directory.

Automatic window **18:20:56–19:06:38 NZDT, 45 minutes 42 seconds**, including diagnosis, changes, reruns, browser checks and records, excluding later commit work. Existing R 4.6.1/Shiny 1.14.0/Python were used. Reports contained hashes/exit codes. Course PDFs/downloads/text, temporary scripts/logs and libraries remained local. Task-owned temporary browser/services closed during wrap-up. Human time was separate from the 15-hour budget.

## 2026-10-31, STATS125 teaching review

The user clarified current STATS125 users and later STATS210 preparation. The four earlier technical fixes were synchronised, with remote read-only verification at `eabd184`. Earlier unpushed notes retain their dates.

| Work ID | Work | Result/scope | Human time at that stage |
|---|---|---|---|
| TEACH-01 | 2026 STATS125, 2024 STATS210, Tutorials 4/6/7/8, test information/formulas | Eight PDF hashes, seven rendered pages, conditional/total/transformed expectation and variance core, selected-resource review | Pending |
| TEACH-02 | Ten Joint, 13 Conditional, nine Expectation and 15 Overview models | Proposed 20 core/8 preview/4 further, with interface/scoring changes pending | Pending |
| TEACH-03 | T125-01–09, prerequisites/glossary/route and eight original discrete proposals | Rational checks, possible cards setting and parameter-range gaps identified | Pending |
| FIX-TEACH-01 | Shepherd direction, Uniform intervals, approximation symbols, positive Gamma assumptions and E5 variance explanation | Original 32 answer/fraction/name/pair/tolerance fields matched baseline, wording fixes completed | Pending |
| TEST-TEACH-01 | Actual-module regression, Auckland report dates, parsing, hashes, 32-row catalogue, links/tables | **300/300**, historical 537, 10/10 and 13/13 retained, without new browser/full historical rerun | Pending |

Deliverables were [teaching review](TEACHING_REVIEW_STATS125.md), [scope/exact examples](evidence/teaching_scope_2026_10_31.json), [regression](evidence/teaching_regression_2026_10_31.json) and updated COURSE_MAP/ISSUES/README/HANDOVER. Local title `Review STATS125 teaching scope and clarify exercise wording`, unpushed/undeployed then. PDFs/text/pages/scripts stayed local.

Automatic window **16:29:42–16:56:46 NZDT, 27 minutes 04 seconds**, including selection, course/question comparison, wording, exact mathematics, regression and records, excluding final commit work.

## 2026-10-31, core paths, exercises and plot parameters

| Work ID | Work | Result/scope | Human time at that stage |
|---|---|---|---|
| CONTENT-01 | Core/preview/further routes, independent filtering/navigation/counts | Default 30 core, 8 preview, 4 further, count-once completion | Pending |
| CONTENT-02 | Retain 32, implement eight proposals and two discrete parameter questions | Ten additions covering CDFs, marginals, independence, conditions/zero marginals, parameters, means, E[XY], second moment/variance | Pending |
| CONTENT-03 | Shared multi-field display/checking with two hints/solution | All fields required, original 32 answers matched 7852cc1, written explanations manually assessed | Pending |
| CONTENT-04 | Three PMF examples, 15 plot presets and x/parameter loading | Poisson 12/24, Normal 50/65 and Uniform 100/140 reproducible, interactive changes preserve fixed question answers | Pending |
| CONTENT-05 | Prerequisites/glossary, core conditional/total expectation, three-model preview/collapsed formulas | T125-01/02/04/05/08/09 implemented, 03 adds two parameter questions, 06 adds order guidance | Pending |
| TEST-CONTENT-01 | R1-04/05/06/remaining reruns, new route/app checks and mathematics | 537+158=**695/695**, mathematics **10/10**, transient route-navigation fix covered | Pending |
| UI-CONTENT-01 | Independent Chrome, table/plot loading, two tabs and 1266/900 widths | **22/22** flow, **13/13** images, local screenshots | Pending |

See [content verification](evidence/content_verification.md). Teaching/issue/course/handover/readme records were updated. Helpers/presets were independent of course PDFs. Progress was session-local. Teacher/user evaluation remained pending.

Local title `Implement STATS125 core learning paths and practice`, unpushed/undeployed then. Earlier evidence and local-only materials were preserved. New preview stayed on 7130, with earlier 7125 unchanged. The independent verification browser closed afterward.

Automatic window **21:37:45–22:18:32 NZDT, 40 minutes 47 seconds**, including implementation/diagnosis/regression/browser/records and excluding later fingerprint/commit work. Existing R 4.6.1/Shiny 1.14.0/Python and cached Playwright CLI were used.

## 2026-10-31, practice access, clipped text and space

| Work ID | Work | Result/scope | Human time at that stage |
|---|---|---|---|
| UI-05 | Reproduce narrow theory, hidden questions, empty Joint column, long options and overlapping formulas | U1-01–07, 213px theory versus about 420px content at 1266px, zero-width hidden inline formulas | Pending |
| UI-06 | Home/module shortcuts and primary practice/table layout | Wide columns/narrow stacks, full-width theory, 2D first, collapsed 3D, compact input rows | Pending |
| UI-07 | Table alignment, wrapping/arrow space, sidebar/plot resizing and typesetting | Tables fit four widths, theory about 969px, Bernoulli formula about 152.7px | Pending |
| TEST-UI-05 | Retain module/path/math assertions | **695/695**, independent **10/10**, original answers, 30/8/4 and game rules retained | Pending |
| TEST-UI-06 | Four modules/widths, focus, sidebar, 3D, dark mode and formula widths | Layout **77/77**, student flow **22/22**, images **13/13**, CSS/JS HTTP/SHA **2/2** | Pending |

See [layout verification](evidence/layout_verification.md). Shared sections and layout CSS/JS were added independently of course files. Updated issue/teaching/handover/readme records, preserving content_*, final_* and original evidence. Local title `Improve practice access and responsive learning layout`, unpushed/undeployed. Preview remained 7130, earlier 7125 unchanged. An independent browser profile was closed after checks. Selected local-app screenshots/JSON were retained, with raw screenshots/logs/course files/dependencies/cache excluded.

Automatic window **22:56:18–23:22:23 NZDT, 26 minutes 05 seconds**, through parsing/screenshots/source checks, excluding final documentation/commit work. Existing R 4.6.1/Shiny 1.14.0/Python/Playwright were used.

## 2026-10-31, teaching/layout synchronisation

The user requested the three local commits be synchronised to origin/main, HI1003/Shiny-Visualization-Project, preserving history.

| Commit | Work |
|---|---|
| 7852cc1 | STATS125 teaching review and wording |
| 09a0f90 | Core/preview/further routes, core questions and plot loading |
| c534e81 | Practice access, responsive layout and clipped text/tables/formulas |

Pre-push review checked **61 paths and 83 file versions** across all intermediate commits. Ignore probes covered course references, .local/, .R-library/, .playwright-cli/, output/playwright/, .Rhistory and .RData. No ignored/tracked files or course/download/dependency/cache files were found in scope. Existing app screenshots and authored evidence were retained.

Existing results/fingerprints were rechecked rather than rerun, including **695/695** modules, **10/10** mathematics, **77/77** layout, **22/22** flow, **13/13** images and **2/2** resources. Remote main matched content SHA `c534e819ecd53e4081a41573b5f559cdb8222094`. Log/handover/review README synchronisation notes followed in a separate documentation commit, with final SHA in Git history and a clean matching local/remote state. Upstream/deployment were outside this action. Human time remained pending then.

## 2026-11-01, concepts and visualisation first

The user noted existing quizzes/assignments and prioritised reviewing ideas and understanding plots, with optional practice and potential interest in sourced exam questions. This expressed a design preference.

| Work ID | Work | Result/scope | Human time at that stage |
|---|---|---|---|
| TEACH-04 | Review → explore → optional self-checks, with concise key ideas/prompts | Concepts visible, definitions/formulas expandable, plots usable without answers, course levels retained | Pending |
| UI-08 | Home enters review, practice/progress collapsed at the bottom | 42 questions and 30/8/4 optional groups retained | Pending |
| SOURCE-01 | Exercise/exam provenance labels | Ten new originals labelled, 32 project exam sources unverified, exam selection pending | Pending |
| TEST-TEACH-02 | Module/math/browser/optional-practice regression | **695/695**, **10/10**, concept browser **65/65**, optional flow **22/22**, images **13/13**, CSS/JS **2/2**, matching hashes | Pending |

See [concept-first verification](evidence/concept_first_verification.md). Teaching/issue/readme/handover records updated, earlier evidence preserved. Local title `Prioritize concept review and visual exploration`, unpushed/undeployed at that stage, with previous 5063d1d synchronisation unchanged and preview on 7130.

Automatic window **14:43:30–14:53:31 NZDT, 10 minutes 01 second**, covering implementation/regression/browser/records, excluding earlier reading and later documentation/commit work. Course files/dependencies/extracts/browser state/logs remained local.

## 2026-11-01, selected past exams replace original student exercises

The user requested genuine past exams only. Four session paper/solution pairs were screened, with four subpart groups selected from three sessions, source-checked and independently calculated.

| Work ID | Work | Result/scope | Human time at that stage |
|---|---|---|---|
| EXAM-01 | Select extracts matching four modules | 2026 S1 Q2(a)–(d), 2025 S1 Q3(c)–(d), 2024 S2 Q3(e), 2026 S1 Q3(d), (g), indexed pages/fingerprints | Pending |
| EXAM-02 | Source/adaptation labels and equivalent presentation | Expectation piecewise PMF to equivalent table, other layout/input changes, written arguments manually assessed | Pending |
| EXAM-03 | Local bank integrated into four modules | Ten original builders removed, 32 internal, four verified optional groups with concept-first/collapsed entry | Pending |
| EXAM-04 | Question table/plot loading and source verification | PDF fingerprints/schema/PMF checked, no fallback, coordinate type mismatch in example recognition fixed | Pending |
| TEST-EXAM-01 | Historical regression plus exams/browser/mathematics | **617/617** (537+80), original mathematics **10/10**, selected **7/7**, Chrome **66/66**, images **13/13** | Pending |
| PRIVACY-EXAM-01 | Exclude course files/bank/raw CLI/screenshots at this stage | Contents under .local/, PDFs on G:, screenshots output/playwright/, general code/metadata/summaries versioned | Pending |

See [selection](PAST_EXAM_SELECTION.md) and [verification](evidence/past_exam_verification.md). Earlier 42/30/8/4/695 records remained historical. Generic presets and the independent game retained their identities.

Local title `Use verified local STATS125 past-exam extracts only`, unpushed/undeployed then. Concept-first `2eed4f9` was also unpushed, with earlier `5063d1d` status retained. Preview remained 7130 and prior 7125 unchanged. At that date another computer required a separate authorised materials handover.

Automatic window **14:56:54–15:24:30 NZDT, 27 minutes 36 seconds**, through results/source fingerprint checks, excluding final docs/exclusions/commit. Existing R 4.6.1/Python/Poppler/cached Playwright were used. Human time was separate.


## 2026-11-01, concept/exam revisions synchronised

The user requested origin/main synchronisation of `2eed4f9` (concept-first, collapsed practice/progress) and `b94764d` (four verified local STATS125 exam groups with local contents).

After fetching remote state and confirming a fast-forward, review covered **56 paths, 66 versions and 65 distinct contents** across both commits. Scope excluded PDFs/archives/bank/text/build scripts/raw browser output/cache. Six historical concept screenshots were visually reviewed as generic concept/plot pages. Exam screenshots remained under ignored output/playwright/.

Ignore probes covered .local/past-exams/, .local/exam-selection/, .local/course-review/, .R-library/, .playwright-cli/, output/playwright/, local_reference/, .Rhistory and .RData. No ignored/tracked file was found. Per-version review checked PDF signatures and private question/solution text. The source index retained year/question/filename/page/fingerprint metadata.

Existing results were rechecked without new app changes or functional reruns, comprising **617/617** modules, **66/66** exam browser, **10/10** original and **7/7** selected mathematics, and **13/13** images. Current exam R MD5 and six source SHA-256 values matched. The older remaining report retained its pre-container-cleanup fingerprint. The earlier TEST-TEACH-02 browser count was corrected to its actual **65/65**, separately from the exam **66/66**.

At **15:29:20 NZDT**, remote main matched `b94764d412ad16f6420b37092b09243869bf8e36`. Log/handover/review README notes followed in a separate documentation commit, with final SHA in history and final local/remote/clean-tree verification. Upstream and hosting were outside the action. At that stage cloning delivered code/metadata/records, with exam contents held separately. Human time remained pending then.

## 2026-11-04, compact probabilities with retained precision

The user first requested coursebook comparison and then approved the display proposal. Coursebook p97/113/114/119/148 were checked locally. Four places was an interface choice.

| Work ID | Work | Verification/scope | Human time at that stage |
|---|---|---|---|
| FMT-01 | Separate display from full values, retain untouched compact bindings | Eight repeated Generate operations per module, actual editing, Normalize/Generate, negatives and shared state | Pending |
| FMT-02 | Shared Auto / Short decimals / Simple fractions | Matching table/formula styles, four places, no trailing zeros, denominator ≤500 and unchanged PMFs on format switches | Pending |
| FMT-03 | Approximation marks, tiny values and more precision | ≈ in cells/steps, .00005 half-rounding fix, hover and expandable precision | Pending |
| TEST-FMT-01 | Updated display assertions, historical/module/exam regression and precision checks | **102+11+124+300+80+72=689/689**, independent **10/10**, real plot/full-value assertions | Pending |
| UI-FMT-01 | Chrome formatting, actual editing/repeated generation, precision and four widths | **29/29** browser, **13/13** images, visually reviewed wide/phone screenshots | Pending |

See [number-display verification](evidence/number_display_verification.md). The final numbers_* reports follow the half-rounding fix. Historical reports remained separate. Synthetic numeric fixtures were test data, with original static source contents retained. Source PDFs/page images/private data/dependencies/screenshots/logs stayed local at that stage.

Local title `Use compact probability displays without losing precision`, unpushed/undeployed then, with earlier `a3a195c` synchronisation retained. Preview remained 7130, only task-owned services restarted, user Chrome refreshed and the independent verification browser closed.

Automatic window **11:35:21–11:49:44 NZDT, 14 minutes 23 seconds**, excluding earlier reading/design and later docs/source/index/commit work. Human time remained separate.

## 2026-11-04, numeric-display synchronisation

The user requested synchronisation of `ecef621`, `Use compact probability displays without losing precision`, to HI1003/Shiny-Visualization-Project origin/main.

Pre-push review fetched remote state and checked **27 paths and 27 versions**. Course PDFs/archives/private questions/solutions/cache and screenshots were outside this range. Ignore probes covered the bank, number-format working directory/logs, libraries, browser state/screenshots, course references and R session files. No ignored/tracked files were found.

Existing **689/689**, **29/29**, **10/10** and **13/13** reports/source MD5 were rechecked against current code, without functional reruns. At **11:55:40 NZDT**, remote main and local content matched `ecef62163f4f4e74c99c989bbe6d4430c84ae26d`. Documentation updates followed in a separate synchronised commit, with final SHA in history and local/remote/clean-tree verification. Earlier unpushed entries retain their dates. Upstream/deployment remained outside this action. Course/bank/cache contents remained local then.

## 2026-11-10, Overview step 2 heading

The user saw step 1 followed by step 3. Parameters/plots existed inside two unnumbered cards. Added **2. Explore plots and parameters** across the exploration area, changing one UI line and a grid-title style.

R parsing passed. Browser checks at **1600px and 390px** confirmed 1→2→3 order, full-width step 2 before both cards and no page overflow. The user's external browser refreshed. Temporary records stayed in ignored folders. Existing numbers_* evidence retained its date/fingerprints. This reversible title/style patch added no permanent test and did not rerun numerical regression. Local title `Label Overview visualization as step 2`, unpushed/undeployed then.

## 2026-11-10, heading column and stale browser assets

The user's screenshot placed step 2 in a narrow left column, controls on the right and plots below. The original browser had loaded new UI with an old unversioned CSS file. Its heading was 28px with grid-column auto. The previous fresh-browser-only check missed this cached-window case.

Step 2 became a full card like step 1, with its heading outside the grid, which now contains only parameter/plot areas. Wide screens use compact left controls and right plots, narrow screens stack. The old cross-column heading rule was removed and internal headings reduced. CSS/JS URLs gained content-based versions.

R parsing and **19/19** target-browser checks passed across 1600/1266/900/390px, heading placement/size, columns/stacks, overflow, versioned resources, model loading and preview. At 900px, the 855px course container exceeded the existing 840px two-column threshold, with 250/547px parameter/plot widths. At 390px it stacked. The actual original 1536px window then showed the new 18.4px heading above the cards with no overflow, visually checked.

See [layout fix evidence](evidence/overview_layout_fix.json) for structure/cache checks and three-file SHA-256 values. Calculations, format rules and questions were outside this patch, with historical numerical reports retained. Temporary scripts/output/screenshots stayed ignored. Local title `Fix Overview section layout and stale assets`, both UI commits still unpushed/undeployed then. Chrome ended at the corrected step 2.

## 2026-11-10, remove probability display selector

The user removed Probability table display. Its selector/listener were deleted and automatic compact formatting became universal, retaining fractions/short decimals, approximation marks, full computational precision, hover details and the then-existing More precision. Internal format helpers remained tested.

Existing checks were updated, with **72/72** precision/app and **29/29** browser cases. Coverage included default automatic mode, ignored obsolete inputs, real editing/repeated generation, removed selector, shared precision and 1600/1266/900/390px layouts. See [precision](evidence/auto_display_precision.json) and [browser](evidence/auto_display_browser.json). Matching source fingerprints were recorded, with older numbers_* evidence retained. The user's browser refreshed. Local title `Remove probability display selector`, unpushed/undeployed then. Course/private/screenshot/cache contents stayed local.

## 2026-11-10, remove sidebar totals and Home shortcuts

The user removed Optional past-exam progress from the sidebar and Home's Review STATS125 concepts / Explore joint probability buttons. Module menus, optional questions, local progress and feedback remained. Unused summaries/callbacks/styles were cleaned up.

Current browser checks switched to sidebar navigation and per-module counts. Table assertions were updated to parse mathematical coordinates rather than compare visible minus-sign strings after MathJax rendered Unicode. Values were checked after actual table updates.

Results were **80/80** exam/app and **66/66** browser checks, covering navigation, checking/progress, route-switch progress retention, removed controls and 1600/1266/900/390px question layouts. See [module checks](evidence/local_progress_regression.json) and [browser flow](evidence/local_progress_browser.json). Source fingerprints matched, with numbers_* and auto_display_* retained historically. The user browser refreshed. Local title `Remove sidebar progress and home shortcuts`, unpushed/undeployed then, with private/course/test/cache materials local.

## 2026-11-10, UI synchronisation

The user requested these four commits be synchronised to origin/main.

- `e700365` added Overview step 2.
- `ff8c390` corrected section layout and stale assets.
- `d2dc5da` removed format selection.
- `ba353d5` removed sidebar totals/Home shortcuts, retaining module feedback/progress.

After fetching, the **16 paths, 28 versions and 28 distinct contents** were reviewed. Ten ignore probes covered bank/fixtures/logs/number work/library/browser/screenshots/course references/R sessions. No excluded file or ignored/tracked file was found. The audit script/raw output stayed under .local/.

Existing reports/fingerprints were rechecked, with current local_progress_* **80/80**, **66/66**, auto_display_* **72/72**, **29/29** at d2dc5da and layout **19/19** at ff8c390. LF/CRLF differences were considered when comparing historical fingerprints. Older numbers_* remained dated numerical evidence.

`git ls-remote` confirmed remote/local content SHA `ba353d5c058ae0de2d191cf63260888001312845`. Separate log/handover/review README updates followed and final SHA/status were rechecked. Upstream and deployment remained outside this action. Materials/cache stayed local, with automatic synchronisation time recorded separately.

## 2026-11-12, student-task walkthrough

Chromium followed Home, seven discrete Overview models, three preview models and eight legacy continuous models, then Joint/Conditional/Expectation, four exam groups and seven game chapters. Coverage included table editing/actions, invalid recovery, directions/zero conditions, auto examples, 2D/optional 3D, wide/narrow layouts and themes. Representative pages were visually inspected.

UX-01–06 fixed exam-to-explore positioning, retained directions/valid conditions across examples, empty game feedback without penalty, top-of-chapter positioning on start/next/back/restart, game contrast and dark Expectation heading contrast. Question counts/answers/models/full-precision rules were retained.

Results were R1-04 **102/102**, R1-05 **11/11**, R1-06 **124/124**, remaining **301/301**, exams/app **87/87**, precision **76/76**, mathematics **10/10**, images **13/13**, exam browser **68/68**, display browser **33/33**, plus targeted Overview/further/table/editor/game/theme walks. Initial early-feedback assertions were corrected to wait for actual output updates. A rapid cold-navigation blank remained a follow-up.

See [student review](STUDENT_EXPERIENCE_REVIEW_20261112.md) and [summary/fingerprints](evidence/student_experience_20261112.json). Priorities were Joint probability magnitude, total-expectation weighting and simpler editors/text. Raw/private/course/cache material remained local, with public summaries limited to coverage/counts/fingerprints. No new commit/push/deployment occurred at that stage.

## 2026-11-13, Joint numerical heatmap

The user approved replacing the Joint scatter plot with a heatmap. X rows/Y columns match the probability table. A fixed 0–1 colour scale, four-place approximate labels/hover readings and categorical cell widths show the probabilities. Absent combinations use the same zero interpretation as the table. Full numerical values are retained.

R1-06 expanded to **132/132**, covering six valid input classes, heatmap rows/columns/labels, one outcome and sparse negative/uneven coordinates. Display browser checks passed **33/33**. A 390px 2×3 table was additionally checked, with approximately 42.7px labels fitting 51.3px cells and zeros shown as 0. Screenshots were visually reviewed. Logs/screenshots stayed in .local/heatmap-review/ and output/playwright/. The 12 November evidence retained its original version.

External Edge displayed the 20-observation example with .3,.2,.1,.4. Other suggestions awaited user decisions. The round was uncommitted/unpushed then, with source/private/cache materials local.

## 2026-11-13, weighted total expectation

Expectation gained conditional-mean, marginal-weight and contribution rows plus the actual weighted expression. A stacked contribution bar used table-row colours and a dashed overall-mean marker. The existing E[Y|X] / E[X|Y] selector controlled direction. Generated table edits updated the display. Zero-weight groups showed undefined conditional means and zero contributions, with valid groups used in the arithmetic. Signed contributions extended on both sides of zero.

Full-precision calculations reused existing number formatting. R1-06 reached **146/146**, covering six input classes in both directions, weighted/direct means, plot sums and signed cases. Browser **9/9** covered direction, unequal weights, zero groups, editing, 1440/900/390px and dark mode, with visually checked screenshots. Logs remained in .local/total-expectation-review/ and output/playwright/.

Google Chrome displayed E[X|Y] for the 20-observation example, with means .25 and 2/3, probabilities .4/.6, contributions .1/.4 and total .5. Other suggestions remained for user choice. The round was uncommitted/unpushed at that stage.

## 2026-11-13, step numbering and text width

Expectation had steps 1 and 3 because the shared heading logic labelled only a separate plot card. Its exploration was inside the table card. The title became **2. Explore tables and expectations**, and the four-module browser suite gained continuous step-order assertions.

The prior 95ch prose limit had been removed. At 1600/1266/900/390px, all four modules used the full explanation container. At 1600px text fit one line, while narrow views wrapped naturally. Exam/browser checks passed **88/88**, bank/app **87/87**. Home, seven discrete, three preview/eight legacy continuous models and game intro/seven chapters/feedback/ending additionally passed **55/55** layout checks at 1600/900/390px. Phone Home and full Expectation were visually reviewed.

Chrome showed loaded tables/expectation and steps 1/2/3. See [evidence](evidence/layout_steps_20261113.json). Raw/private/screenshots stayed ignored. No new commit/push then.

## 2026-11-13, Home learning-route wording

The long italic paragraph became four steps covering foundations, discrete models, joint/conditional probability and conditional/total expectation. Chapters/module names remained, with one concise optional game/exam note. STATS210 preview/further guidance moved into an initially collapsed section, retaining the Overview Learning path entry.

Chrome at 1600px/390px showed four normal-text steps, no page overflow and working expanded/collapsed options. Both screenshots were visually reviewed and Chrome ended at Home. Files stayed ignored and the round was uncommitted/unpushed then.

## 2026-11-13, disjoint model paths

Further exploration originally duplicated preview's Uniform/Exponential/Normal. Student catalogues became disjoint, with seven core discrete, three preview continuous and Gamma/Beta/Chi-Squared/Student's t/F further models. Home/path explanations matched the catalogues.

Uniform/Exponential/Normal parameter examples moved to preview, two per model, retaining scenarios/values. Invalid model selections switch to a valid model on path changes. Legacy checks retain all eight continuous models.

Five path/example assertions were added, giving **92/92** exam/app and **301/301** model/remaining checks. Browser **20/20** covered disjointness, six preview examples/loading, five further plots, return-path selections, core retention and wide/phone layouts. Results stayed in .local/path-review/. Chrome displayed five further models. Uncommitted/unpushed then.

## 2026-11-13, Bernoulli definition and exploration prompt

The user found the prompt abrupt. The CDF definition gained F(0)=P(X=0)=1−p for binary support. The prompt referred to the Success probability slider and p versus 1−p, summing to 1. Variable naming became X throughout Bernoulli definitions/formulas.

Chrome verified p=.2/.8 giving F(0)=.8/.2, rendered formulas and 1440/390px layouts without page overflow. The concept card was visually checked. Temporary evidence stayed ignored, Chrome ended at Bernoulli and the round was uncommitted/unpushed then.

## 2026-11-13, remove exploration-task prompts

The user explicitly removed What to explore / Try this with the plots below from all 15 Overview models and the three table concept cards. Unused learning-observe text/styles were removed. Definitions, probability concepts, formulas, example contexts, necessary controls and optional exams remained. Home/game instructions were checked.

R parsing, **18/18** browser checks and git diff --check passed. Every model/table module rendered its concepts/plots with no visible Shiny error. Bernoulli was visually reviewed and retained in Chrome. Temporary scripts/logs/screenshots stayed ignored. No new commit/push then.

## 2026-11-13, linked hover and duplicate readings

The user approved same-x PMF/CDF hover and removed Current Selection. Seven discrete/eight continuous models moved to Plotly client interaction, linking both plots, clearing on mouse leave and avoiding an R redraw per pointer movement. Compact four-place/approximation formatting retained full calculation precision. Old click selection/permanent labels/two duplicate panels were removed and the heading became Distribution plots.

CDF steps retain open/closed endpoints and use included endpoints for F(x) readings. Continuous plots linked the same sampling grid at this stage, with density/singular-endpoint explanations. Touch selection retained both tooltips after a native touch-end timing fix. Parameter changes cleared stale readings. Joint/Expectation instructional numeric decompositions remained visible.

Generic check_distribution_hover_browser.js passed **54/54**, covering 15 models, both directions, endpoints, leave, updates, 1600/900/390px and two repeated touch-emulation taps. Screenshots were visually reviewed. Other/display browser **33/33**, model/remaining **301/301**, exam/app **92/92** and precision **76/76** passed, along with JS syntax/diff checks. See evidence/distribution_hover_20261113.json. Touch coverage was Chrome emulation. Review/report/work-log entries updated, original comparison retained and the round stayed uncommitted/unpushed/undeployed.

## 2026-11-13, axes and displayed range

The approved axis treatment added thin axis lines and short ticks. Bernoulli's paired range was −1 to 2, with ticks −1,0,1,2. Other discrete models used integer ticks selected for their range. PMF/CDF probability ticks were 0,.2,.4,.6,.8,1 with upper space, and zero CDF endpoints remained fully drawn.

Continuous x padding became 6% of the interval instead of a fixed ±1, preserving narrow Normal/Uniform shapes. Density axes could exceed 1. Repeated touch taps had triggered auto zoom and mismatched axes, so ranges were fixed and default double-click zoom disabled. Touch-end retention and repeated-tap range assertions were added.

Browser **116/116** covered all models' axes/ticks/range matching, linked readings, layouts/touch and Normal sd=.01/Uniform [0,.1]. R model/remaining **301/301**, JS syntax and diff checks passed. Bernoulli wide and narrow-Uniform phone screenshots were visually checked. Evidence stayed in .local/axis-review/ and output/playwright/.


Chrome ended on Bernoulli p=.4 for inspection. Source/private/cache materials remained local and the axis round was uncommitted/unpushed then.

## 2026-11-13, remove parameter-example selectors

The user removed all 15 distribution example dropdowns and blue explanations. Parameters and examples became Parameters. Unused preset observers/explanations/state were removed. Exam scenarios and their loading button continued using the parameter loader and moved the viewport to the plots.

Updated checks retained exam model/parameter/probability assertions, with exam/app **89/89** and Chrome **66/66**, covering 15 distributions, paired hover/touch, layouts and actual loading of both exam scenarios. Wide/phone interfaces were visually reviewed. R/JS syntax and diff checks passed. Chrome ended at Bernoulli p=.4 with optional questions collapsed. Temporary fixtures/logs/screenshots stayed in .local/preset-removal/ and output/playwright/. The round was uncommitted/unpushed then.

## 2026-11-13, remove hover instruction

The user removed Hover to read values / tap on a touchscreen beneath discrete/continuous plots. Continuous density explanations remained. R parsing, actual core/preview browser checks and diff checks passed. Chrome ended at Bernoulli's plots. Temporary checks stayed ignored and the round was uncommitted/unpushed then.

## 2026-11-13, discrete CDF interval readings

Bernoulli's x<0 zero plateau had no reading because hover was limited to filled jump markers. Queries now use the pointer's x across the left-zero, between-integer, jump and right-tail intervals. Both plots show the same x. Noninteger/out-of-support point probability is zero. CDF jumps use included endpoints, with near-integer snapping to make exact jump readings accessible.

Drawing/query calculations share discrete model data, adding a right-boundary integer for correct unbounded-support readings. Compact R formatting/approximation markers are reused. Touch supports intervals. New assertions cover plateaus, either side of jumps, outside support and clearing after leave.

Browser **87/87**, touch-interval emulation **4/4**, R model/remaining **301/301**, R/JS syntax and diff checks passed. Coverage included seven models' left-support intervals, Bernoulli left/middle/right/jump points and existing 15-model/layout checks. Interval tooltips were visually checked. Chrome ended on F(x)=0 at the left interval. Logs/screenshots stayed in .local/cdf-interval-review/ and output/playwright/. Uncommitted/unpushed/undeployed then.

## 2026-11-13, CDF tail arrows

The first requested design added outward arrows on constant CDF tails. Bernoulli/Binomial/Hypergeometric/Discrete Uniform and Uniform/Beta showed constant zero/one tails. Exponential/Gamma/Chi-Squared/F showed left-zero arrows. Poisson/Geometric/Negative Binomial and unbounded continuous tails used limiting F(x)→0/1 labels, with p=1 Geometric/Negative Binomial constant right tails.

Large-range discrete models gained left padding, and both plots retained shared x ranges. Bernoulli stayed −1 to 2. Browser **123/123**, R **301/301**, syntax/diff checks passed, including all 15 models, two degenerate cases, wide/390px Geometric, hover/interval/touch/layout. Bernoulli/phone Geometric were visually checked. Chrome showed Bernoulli p=.6. Logs/screenshots stayed under .local/cdf-arrows/ and output/playwright/. This temporary design was uncommitted/unpushed/undeployed.

## 2026-11-13, clarified x-axis arrows

The user clarified that the coordinate axis should indicate extension. CDF curve arrows/limit labels and extra left padding were removed. Both plots instead gained grey x-axis endpoint arrows matching the axes. Bernoulli retained −1,0,1,2 ticks.

All 15 models' arrow positions, paired hover, CDF intervals, layouts/touch and Gamma singular-density annotation were checked. Duplicate arrow merging was corrected, and measurements waited for stable scrolled layouts. Browser **103/103**, R/JS syntax and diff checks passed. The final Bernoulli p=.6 view was visually checked, with ordinary CDF segments and arrows on bottom axes. Evidence stayed in .local/x-axis-arrows/ and output/playwright/. Uncommitted/unpushed/undeployed then.

## 2026-11-13, remove axis arrows

The user decided to remove arrows. Shared arrow generation and obsolete assertions were removed. R/JS syntax, diff checks and actual discrete/continuous browser checks passed. Bernoulli p=.6 was visually reviewed and retained in Chrome. Evidence stayed ignored and the round was uncommitted/unpushed then.

## 2026-11-13, clearer exam-loading button

The user approved **Load question parameters into plots**. Browser-script wording was aligned. Syntax/diff checks and actual Chrome checks confirmed the new name and removal of the old one. Chrome ended at that button. Temporary checks stayed ignored and the round was uncommitted/unpushed then.

## 2026-11-13, temporary parameter-control redesign

The user questioned .01,.11,.21 ticks. The then-current review established .61 was a valid probability and the grid offset came from a .01 minimum. A temporary change removed dense grids from 24 sliders, retaining minimum/current/maximum, and set Poisson step .01.

Uniform's temporary bounds allowed negative/positive ranges, a from −10 to 199.99, b up to 200 and b≥a+.01, moving b when needed and loading upper constraints first. Hypergeometric initial n/M bounds were aligned with N=20 rather than 30. Other positivity/integer/probability boundaries were checked. The 20-observation example gave conditional values .2 and 1/3, and expectation directions restored E[X]=.5/E[Y]=.6.

Temporary generic check_parameter_controls_browser.js passed **78/78**, covering all controls, Uniform signs/equal/upper bounds, Hypergeometric linkage, updates and 1600/390px. R remaining **301/301**, R1-05 **11/11**, R1-06 **146/146**, exam/app **89/89**, syntax/diff checks passed. Controls were visually checked and Chrome showed Geometric p=.61. Evidence stayed in .local/parameter-review/ and output/playwright/. This design was later withdrawn.

## 2026-11-13, withdraw temporary parameter redesign

The user clarified the question concerned .61 versus .6/.7 parameter choices and requested the original controls. All 24 grids, Poisson step, Uniform ranges/loading and Hypergeometric initial/range logic were restored. The temporary browser script was removed. Previously approved plots/hover/exam loading remained. Probability step .1 was not introduced in that rollback.

R parsing/diff checks passed. Automatic approval blocked restarting the owned preview and a replacement launch. Source was restored, while the existing Chrome session still showed in-memory grid=false controls. Browser refresh/visual verification was left pending at that point. The previous redesign evidence referred only to the withdrawn version. No new commit/push occurred.

## 2026-11-13, refresh rollback preview and verify grids

The user reported grids still missing. Port 7130 was confirmed as the task's .local/content_start.R process and was stopped/restarted successfully. Chrome reload confirmed grid=true for all 24 sliders and Geometric p=.61 ticks .01,.11,.21,…,.91,1. The screenshot was visually checked. This completed the prior pending preview refresh. Steps/plot axes stayed restored, and temporary evidence stayed ignored. No new commit/push occurred.

## 2026-11-13, numeric parameter inputs and slider synchronisation

All 15 distributions and 24 parameters gained numeric inputs beside labels. Enter/blur commits, with dragging/server updates reflected back. Input ranges track sliders. Integer parameters require integers. Empty/nonfinite/out-of-range/invalid Uniform inputs show inline feedback and retain valid plotting values.

Fine manual input initially refined slider steps to retain values, fixing Poisson .61 rounding to .6. Numeric increment buttons initially defaulted to .01 and followed finer precision. Hypergeometric initial/later n/M bounds follow N. Enter completes and exits editing to prevent focus/duplicate-submission problems when resuming dragging.

Staged browser checks covered all models/controls, bidirectional updates, bounds, empties, integers, Uniform bounds and shrinking Hypergeometric populations. Final interaction **10/10** passed, with actual post-input dragging and all 24 numeric/slider bounds compared. Wide1600/phone390 screenshots were visually checked. Chrome showed Bernoulli p=.61. R remaining **301/301**, syntax/diff checks passed. Generic check_parameter_inputs_browser.js was added.

G: was unavailable at that moment, so source PDF validation and exam-loading end-to-end checks awaited its return. Temporary checks/logs/screenshots remained in .local/ and output/playwright/.

## 2026-11-14, exam loading after G: recovery

The restored bank/source papers and solutions passed **89/89**, then the owned preview restarted to load verified materials.

Both actual exam-load scenarios synchronised distribution, numeric box, slider and plots. Manual edits, invalid input and actual dragging followed by reloading restored the stated parameters and cleared feedback. Every PMF/CDF plotted value matched independent Poisson calculations. Joint/Conditional/Expectation source-table loading also matched the bank. Browser **63/63** passed.

The generic exam browser gained numeric/slider/CDF assertions. JS syntax/diff checks passed. The final loaded Overview plots were visually checked and left in Chrome, completing the earlier blocked test. Private fixtures/logs/screenshots stayed in .local/exam-selection/ and output/playwright/.

## 2026-11-14, concise parameter explanations

Twenty-four parameter explanations were added below sliders and linked to numeric inputs' accessibility descriptions. Hypergeometric n/M/N explain without-replacement sample count, population successes and population size with integer/n≤N/M≤N constraints. Geometric/Negative Binomial describe failure counts. Other descriptions explain success probability, Poisson's full-interval mean, Uniform bounds, rates/waiting times, Normal sd versus variance, shape and degrees of freedom.

Wording was checked against STATS125 Chapter 6 and STATS210 Chapter 7, with text-cache fingerprints matching source PDFs. All 15 models/24 descriptions were inspected, including accessible associations, wide/390px fit and actual Hypergeometric M updates. R parsing/diff checks and visual review passed. Chrome showed n=10,M=5,N=20. Temporary checks/screenshots remained ignored.

## 2026-11-14, default steps, ticks and precise loading

All 24 parameter controls gained consistent defaults. Integer counts step by 1, decimal parameters by .1, degrees of freedom by 1 with valid manual fractions allowed. Numeric buttons/keyboard arrows follow the same defaults. Dragging after precise input returns to the default step. Descriptions/range/integer checks remain linked.

Ticks use zero-aligned clean values at their actual positions. Poisson shows 3,6,9,12,…,30, replacing 3.01/6.01 offsets. Slider updates retain fine manual/Shiny values, including scientific-step cases. From 12.01, increasing gives 12.1. Value 12.3456789 synchronises fully to slider/plots. Paired increment buttons avoid browser-native step-base offsets.

Main browser checks passed **360/360**, precision **28/28**, including Shiny messages to 18 noninteger controls with eight-place values, manual precision, negative increments, fractional df and resumed default dragging. Actual exam/table loading passed **63/63**, R remaining **301/301**, exam/app **89/89**, syntax/diff checks. Wide1600/phone390 screenshots were visually checked. Chrome ended at Poisson λ=12.1. Fixtures/logs/screenshots remained ignored.

## 2026-11-14, adaptive continuous x queries

Eight continuous models choose clean query steps from approximately one percent of the base x range, rounded up to 1/2/5×10^k. x readings/axis labels use corresponding precision. Standard Normal uses .1, Uniform [0,1] .01 and [0,100] 1, Exponential rate10 .01, and Uniform [0,.0001] .000001.

PDF/CDF share an R-calculated query table at exactly the same x, with parameter signatures preventing mixed updates. Smooth curves retain at least 600 points and include exact query points. Infinite-density endpoints omit markers while explaining unbounded density and retaining endpoint CDF values. Local mouse/touch interaction replaces unused server hover/click forwarding, with tooltips constrained to mobile plots.

Discrete integer/interval semantics remain. Touch uses paired readings. R continuous **104/104**, remaining **301/301**, continuous browser **157/157** and existing distribution interaction **87/87** passed across models/scales/singular endpoints/directions/updates/desktop/390px touch.

Wide/phone screenshots were visually checked. Chrome's standard Normal reading at x=−1.1 showed density about .2179 and CDF about .1357. Small-axis labels were 0,.00005,.0001. Browser console had no errors/warnings. Evidence remained in .local/ and output/playwright/, with no source-material change or new commit/push then.

## 2026-11-14, hide empty exam panels

The user requested hiding optional question sections/navigation when the current module/path has no verified questions, including removal of the empty-bank blue message. Shared rendering follows current question counts across four modules.

R exam/app **89/89** and exam browser **93/93** passed. Chrome additionally confirmed preview/further sections hidden and core sections restored. Answers, parameter loading, per-module progress and layouts passed. Final screenshot visually checked, with Chrome left in preview. Private fixtures/logs/screenshots stayed ignored.

## 2026-11-14, shared step 2 at exploration top

Joint's numbered heading previously labelled only the right plot. Shared table modules gained an outer step card with the number/title above the entire region and left-aligned with step 1. Internal cards retained Interactive probability table and Distribution plots. Overview's equivalent structure was checked.

R parsing and **64/64** browser layout/navigation checks passed across four modules at 1600/900/390px, confirming alignment, full-section coverage, heading position, no duplicate numbers and no page overflow. Joint wide/phone screenshots were visually checked. Chrome ended at Joint and temporary evidence stayed ignored.

## 2026-11-14, Joint fractions and 3D removal

The user removed Joint's 3D UI/server plot. Heatmap/table share number formatting, preferring exact simple fractions and otherwise short decimals/scientific notation with approximation marks. Cards show 188/221,16/221,1/221, frequencies 3/10,1/5. Hover probability uses up to four places, with full underlying values retained.

Repeated titles, margins, label space and colour-bar text were simplified. Edit table initially collapses so phones first show table/plot. Step 2 covers both regions, side by side on wide screens and stacked on narrow ones.

R1-06 **146/146**, precision **76/76**, specialised browser **21/21**, display browser **33/33**, syntax/diff checks passed. Coverage included table/heatmap fractions, decimal fallback, approximations, removed 3D, editor access, repeated-generation precision and 1600/1266/900/390px. Old 3D assertions and fine-parameter browser actions were updated to current numeric input. Screenshots were visually checked and Chrome ended at Joint. Detailed evidence stayed ignored.

## 2026-11-14, Conditional 3D removal and layout

The user removed Conditional's 3D output. The conditional table/bar share one computed distribution and matching fraction/decimal/approximation formats. Axes show discrete outcomes and conditional probability, with label space and hover for dense cases.

Direction/value controls join the conditional table/plot on the right, with joint table left. Wide table/plot layout becomes stacked on phones. Repeated titles/3D styles were simplified, Edit table collapsed and toolbar selection/zoom controls removed from the visible strip.

A stale-bar defect at zero-probability conditions was fixed by clearing the plot and showing undefined feedback, recovering at a valid condition. R1-05 **11/11**, R1-06 **146/146**, precision **76/76**, browser **33/33**, syntax/diff checks passed. Both directions/values, matching formats, zero/recovery, editor access and four widths were checked. Screenshots were visually reviewed. Chrome showed X=0 with table/bar 47/51,4/51. Detailed evidence stayed ignored.

## 2026-11-14, Expectation formatting/layout

The user requested table-matched bar labels/hover/overall-mean markers. number_reading gained an optional format argument, retaining decimal defaults. Cards contributions became 16/221 and 1/221, with overall 1/13. Narrow contributions used horizontal hover readings.

Probability table/calculation panels sit above a full-width conditional-mean/weight/contribution table and graphic. Editors/calculation steps collapse independently. Wide/phone layouts adapt, with header widths preventing isolated-letter wraps. The overall marker sits upper-right and the toolbar avoids headings.

Precision **79/79** added actual-label/hover assertions in three formats. R1-06 **146/146** covers signed/overall recovery. Browser **36/36** covers directions, fractions/decimals, actual hover, zero/signed groups, editors and four widths. Final 390px header wrapping and wide/phone screenshots were visually checked, with syntax/diff checks passed. Chrome showed E[Y]=1/13. Detailed evidence stayed ignored.

## 2026-11-14, accumulated UI/number publication scope

The user requested synchronisation of the accepted layouts, paths, numeric/slider inputs, steps/ticks, paired queries, 3D removal, weighted expectation, hidden empty questions and general tests/review records. The explicit scope comprised **35 files**, targeting HI1003/Shiny-Visualization-Project main.

Current checks passed R1-04 **102/102**, R1-05 **11/11**, R1-06 **146/146**, remaining **301/301**, exam/app **89/89**, display **79/79**, continuous queries **104/104**, independent mathematics **10/10**, assets **13/13**, total **855/855**. All outgoing JS syntax and diff checks passed. Browser results retained their dated coverage.

Complete outgoing contents were matched against **20** private-bank prose fragments. Eight ignore exclusions covered course/bank/fixtures/dependencies/screenshots/browser/R-cache files. Reports/manifests/fingerprints/audit stayed under .local/. Human time remained pending at that date.

## 2026-11-14, explicit total-expectation multiplication/addition flow

The user found the stacked bar insufficiently explanatory. A dynamic calculation flow replaced it while retaining the table. Each condition shows conditional mean × marginal probability = contribution in its row colour. The lower section adds contributions to the overall mean. The default displays 4/51 × 12/13 = 16/221 and 1/17 × 1/13 = 1/221, followed by 16/221 + 1/221 = 1/13.

The flow/table share weighted data and number formats. Larger fractions aid reading. Long phone decimals use compact fonts and approximation marks on values/relations. Zero-weight groups state undefined conditional means with zero contribution. Signed contributions and cancellation to zero are supported. Directions/examples/edits update the flow, preserving left-to-right multiplication and wrapping addition.

Precision **79/79**, R1-06 **146/146**, browser **28/28**, syntax/diff checks passed. Assertions checked rendered factors/products/sums, both directions, fractions/decimals, zero/signed groups, zero mean, approximation signs, phone decimals and four widths. Wide/phone screenshots and final larger fractions were visually checked. Chrome ended at the flow. Detailed evidence stayed ignored.

## 2026-11-14, expectation-flow synchronisation

Six files comprising the flow, shared style/format support, calculation tests and work log were committed/pushed. Publication review checked the complete files against private text/exclusion rules, with **79/79**, **146/146** and **28/28** results verified. Content commit `91e5faea07f4a41f169928b1c64cfb6b4e5a6c25` matched remote main through git ls-remote.

## 2026-11-14, overall delivery review

A git archive export of that commit contained versioned code without the local bank, course files or dependencies. Its Start-Shiny.R --no-browser installed dependencies and launched on 7125, using R4.6.1, Shiny1.14.0 and Plotly4.12.1. Original 7130 remained for separate bank checks, with the original comparison and other services retained.

The current R/math/assets groups passed **855/855** with the same per-group counts above. Export Chrome checks passed launch/navigation **16/16**, 15 models/24 parameter controls **360/360**, hover/touch **87/87**, continuous x **157/157**, expectation flow **28/28**, game **20/20**, three-module themes/layout **36/36**. Original-bank browser checks passed **93/93**. Browser total **797/797**, with selected wide/phone/theme/game screenshots visually reviewed.

The bank-free export retained core concepts/plots, hid question sections/navigation and returned 404 for the private bank route. Three rapid-navigation rounds after first connection recovered. Input ranges/integers, numeric/slider synchronisation, exam loading, editing, zero conditions, directions, weighted means and restart had specified coverage.

README's clone address and original nested-ZIP instructions were corrected to the user's repo and current versioned Project_PPeek1ng/ plus Start-Shiny.R, preserving authorship. Handover/issues/review entry were updated. This review changed documentation only.

No delivery-blocking issue was found within the stated Windows/Chrome coverage. Teacher/student acceptance and hosting arrangements remained follow-ups. At this date exam handover required separate local materials. Entire historical course directories, all systems/browsers and learning outcomes were outside the review.

Detailed results/export/dependencies/screenshots remained ignored. Five documentation files passed complete-file private-text matching and eight exclusion checks before publication. The later user clarification removed the human-timesheet requirement.

## 2026-11-16, English project and complete bundled exam delivery

The user first requested a local private materials package, then clarified that all project documentation/comments should be English, and finally explicitly authorised publishing the selected question bank and corresponding PDFs with the complete GitHub project. The final publication scope follows that clarification. The contract is signed and no timesheet is required.

The materials package initially collected four question groups and six question/solution PDFs, checked against the stored MD5/SHA-256 values. A configuration helper was tested in a moved directory with spaces. Following the publication request, the app was updated to discover `exam-materials/bank.json` and resolve its source paths relative to the bank. Explicit STATS125_EXAM_BANK overrides remain supported, with the earlier .local bank location available as a fallback. PDF bytes and all question/answer/graph/table data were preserved. Git attributes mark PDFs as binary to retain their fingerprints.

The English conversion covers course mapping, teaching review, issue register, walkthrough, handover, work log, ten historical verification documents, two metadata JSON files and source comments. The nested original ZIP also has English comments. Ten R-expression comparisons verified comment-only changes in the four current and six archived R files, allowing only CSS-comment removal in the comparison. Metadata numbers/fingerprints were preserved. Machine-specific Chinese directory strings in historical source metadata now identify the original source filenames. The current version has 138 text files without Chinese characters, and extracted text from all six PDFs also has none.

Current checks passed R1-04 102/102, R1-05 11/11, R1-06 146/146, remaining 301/301, display 79/79, continuous query 104/104, exam integration 95/95, independent mathematics 10/10 and images 13/13, totalling **861/861**. Six new loader cases cover root/app discovery, relative-path relocation, the resolved moved PDF, explicit override and rejection of a missing relative PDF. A separate clean-copy run passed the same **95/95** exam checks.

A tracked-files-only export in a directory with spaces completed first-run missing-package installation and launched using Start-Shiny.R --no-browser on 7125. Chrome checks passed four-module exam interaction/loading 93/93, total-expectation flow 28/28, seven-chapter game 20/20 and English interface/phone layout 21/21, totalling **162/162**. The app loaded its bank and six PDFs from the exported repository. R libraries used the configured local environment, with missing packages installed automatically in the export. Wide/phone expectation screenshots were visually reviewed.

The publication audit checked all 187 candidate files, 211 local Markdown links, source PDF fingerprints and exact bank equivalence apart from source-path rebasing. The eight added files are the bank, six approved PDFs and their README. Other course-reference material and caches retain existing Git exclusions. Detailed tests, screenshots, extraction caches and audit scripts remain under ignored .local/ and output/playwright/. A complete delivery ZIP is generated from the reviewed commit for local sharing.
