# Module audit and teaching review

Updated on 2026-11-16. Project documentation and source comments are now in English. The four selected exam groups and six matching PDFs are bundled with the repository at the user's request. Their portable setup is described in the [exam-materials record](PAST_EXAM_SELECTION.md). The contract is signed and the user confirmed that no timesheet is required. The current verification passed 861/861 calculation/resource checks and 162/162 browser checks, plus 95/95 exam checks in a clean exported copy. See the current [handover](HANDOVER.md).

The 2026-11-14 interface includes numeric inputs synchronised with sliders, consistent steps/ticks, linked plot readings, and matching table/plot formats. Joint uses a fraction-labelled heatmap. Joint and Conditional have two-dimensional plots. Expectation displays each conditional mean multiplied by its marginal probability and then adds the contributions. Empty optional question sections are hidden. A tracked-files-only export completed dependency installation, launch and browser review. See the [handover and limits](HANDOVER.md) and [work log](WORKLOG.md).

Current generic browser checks include `check_distribution_hover_browser.js`, `check_continuous_query_browser.js` and `check_parameter_inputs_browser.js`. Earlier content/layout/concept scripts describe historical workflows. The evidence below retains the dates and coverage of each original run.

## Dated implementation records

- **2026-11-13.** Overview uses linked hover values at the same x, with touch selection retaining the reading. The duplicate Current Selection panels were removed. Discrete CDFs retain open and closed endpoints. Exploration-task prompts after definitions were removed. Instructional tables and decomposition values remain in other modules. See the [interaction evidence](evidence/distribution_hover_20261113.json). These changes were still local at that stage.
- **2026-11-12.** The [student-task walkthrough](STUDENT_EXPERIENCE_REVIEW_20261112.md) covered four learning modules, four exam groups, seven game chapters, table editing, narrow layouts and light/dark themes. It fixed exam-to-plot positioning, retained conditioning direction, empty game submissions, chapter positioning and text contrast. Joint probability encoding and total expectation were identified for subsequent work. See the [dated summary](evidence/student_experience_20261112.json). That round had not yet been committed or pushed.
- **2026-11-10.** Sidebar exam-progress totals and two duplicate Home shortcuts were removed. Navigation uses the sidebar, with progress and feedback inside each optional question section. The four UI commits were synchronised and the remote content SHA was verified as `ba353d5`. The Probability table display selector was also removed in favour of automatic compact formatting. The older `auto_display_*` evidence and work log describe that stage. No deployment was performed.
- **2026-11-04.** Tables, editors, plot labels and calculations gained consistent compact fractions/decimals, approximation marks and precision-preserving editor bindings. The sidebar then offered Auto / Short decimals / Simple fractions, and Overview offered More precision. Commit `ecef621` was synchronised with a matching remote SHA. See the [number-display record](evidence/number_display_verification.md). The later interface simplified those controls.
- **2026-11-01.** The route became **review concepts → visualise → optional past-exam extracts**. Student question panels contained four verified STATS125 groups with year, semester, question and adaptation labels. The 10 original exercise builders were removed, and the original 32 remained for internal regression only. At this stage source PDFs, bank contents and screenshots containing questions were kept locally. Commits `2eed4f9` and `b94764d` were synchronised and the remote SHA verified. See [selection](PAST_EXAM_SELECTION.md) and [historical verification](evidence/past_exam_verification.md). Earlier references to an unpushed state apply to their stated dates.

The current regression entry point includes the original module fixes and `test_past_exam_bank.R`. Direct module loading uses `pmf_helpers.R`, `past_exam_bank.R`, `learning_content.R` and `learning_practice.R` in that order. Earlier counts of 42 questions, 30/8/4 and 695 checks refer to historical revisions.

## Earlier stages and first audit

An earlier 2026-11-01 revision prioritised concept review, visual exploration and optional self-checks. It kept 42 questions, identifying 10 new originals and 32 project questions with unverified exam provenance. It passed 65/65 concept-first browser checks, 695/695 module checks and 22/22 optional question checks. See the [dated record](evidence/concept_first_verification.md). The later exam-only version superseded that catalogue.

The 2026-10-31 [teaching review](TEACHING_REVIEW_STATS125.md) established STATS125 as the default route, with later STATS210 content optional. That historical implementation kept the original 32 and added 10 core questions, totalling **30 core / 8 preview / 4 further exploration**, with separate filtering and counts. Conditional and total expectation, discrete E[g(X)] and variance remained core. Questions could load matching plot/table parameters and x selections. See the [content verification](evidence/content_verification.md).

The subsequent [layout work](evidence/layout_verification.md) improved question access, clipped text/formulas and use of space. Wide layouts placed tables and questions side by side, narrow layouts stacked them, theory used full width and 3D was initially collapsed. Results were 695/695 module checks, 77/77 layout checks and 22/22 student-flow checks. Their `layout_*` results preserve that version's fingerprints.

The earlier four fix rounds reached baseline `eabd184`. Teaching review `7852cc1`, core content `09a0f90` and layout `c534e81` were synchronised on 2026-10-31, with content SHAs checked against remote main. Teacher/student acceptance and deployment remained pending at that stage.

The first audit was dated **2026-10-21**, Pacific/Auckland, against `0f609deed5caac75f55542ead1a0b4cd808f4f52`. It identified **11 confirmed issues, comprising 8 P1 and 3 P2**, with session isolation requiring further verification. By 2026-10-30 all 11 were fixed and verified, along with seven additional groups involving session isolation, model assumptions, boundaries, restart, assets and themes.

The [2026-10-30 verification](evidence/final_verification.md) records R1-04 102/102, R1-05 11/11, R1-06 124/124, remaining checks 300/300, independent rational calculations 10/10 and image resources 13/13. The evidence identifies the specific inputs and workflows covered.

At that stage the command was `./review/scripts/run_regression.ps1`, writing `final_*.json` by default, or another prefix such as `content`. Run `test_assets.ps1` after starting the app, using `-BaseUrl` and `-ReportPath` as needed. Direct tests pass one shared `new_pmf_state()` to the three table modules within the same session. Internal legacy checks retain assertions for the original 32 questions. The student interface cannot choose legacy.

- [R1-04 verification](evidence/r1_04_verification.md) includes 10/10 rational checks, 102/102 module interactions and reruns of R1-05 11/11 and R1-06 124/124. Run `test_r1_04.R` before `test_r1_04_math.py`.
- [R1-05 verification](evidence/r1_05_verification.md) contains before/after results, 11 actual module cases and browser evidence. Run `Rscript --vanilla review/scripts/test_r1_05.R`. The original `round1_*` expressions are retained as reproductions of the old defects.
- [R1-06 verification](evidence/r1_06_verification.md) covers validation, normalisation, draft/committed state and browser behaviour across the three table modules. That stage passed 124/124 and reran [R1-05 at 11/11](evidence/r1_05_after_r1_06.json). Load `pmf_helpers.R` before standalone module tests.

| Record | Purpose |
|---|---|
| [COURSE_MAP.md](COURSE_MAP.md) | Course sources, chapter/page locations and module mapping |
| [TEACHING_REVIEW_STATS125.md](TEACHING_REVIEW_STATS125.md) | STATS125 focus, question classification, gaps, core exercises and prerequisites |
| [ISSUES.md](ISSUES.md) | Issue IDs, reproduction, expected behaviour, evidence, fixes and acceptance criteria |
| [WORKLOG.md](WORKLOG.md) | Dated implementation and verification history |
| [HANDOVER.md](HANDOVER.md) | Current delivery scope and remaining acceptance items |
| [Browser record](evidence/round1_browser.md) | Original interaction reproductions and coverage |
| [Numerical results](evidence/round1_numeric.json), [joint bank results](evidence/round1_joint.json) | Reproducible numerical evidence |

## Initial coverage on 2026-10-21

| Module | Checked | Depth and limits at that stage |
|---|---|---|
| Home | Navigation, learning order and parameter explanations | Full accessibility review pending |
| Probability Overview | Discrete/continuous entry, default Bernoulli, Geometric explanation, continuous Uniform and source PMF/PDF/CDF implementations | Complete browser parameter coverage for seven discrete and eight continuous models pending. Geometric/Negative Binomial p=1 expressions were checked in R. |
| Game: Discrete | Start, Poisson chapter 1, Discrete Uniform chapter 2, selection, feedback and explanation | First two of seven chapters operated in the browser. |
| Joint | Default table, negative input, Generate, Uniform, question entry/navigation and 10 independent calculations | All bank tables/numbers checked, with only selected hint levels clicked. |
| Conditional | Default table, wrong distribution-name submission, Q4 feedback and 13 question/answer structures | Six numerical calculations and seven name/parameter checks. Full text-acceptance rules needed work. |
| Expectation | Default output, Q4 exact-fraction submission and nine question calculations/structures | Q8 requested two values but checked one. Complete interaction combinations pending. |

Course review used relevant chapters from the two main coursebooks. The downloaded STATS210 complete coursebook is the 2024 edition. Original PDFs, extracted text and page images were held in `G:\STATS` or `.local/course-review/` during the historical review.

## Regression reproduction

```powershell
./review/scripts/run_regression.ps1
```

The script defaults to the local R 4.6.1 and Inkscape Python installations. Override them with `-RscriptPath` and `-PythonPath`. Module checks use the app's R packages and Python's standard library. Past-exam integration needs the bank and matching PDFs. Start `Rscript Start-Shiny.R --no-browser` before running `test_assets.ps1`.

`round1_audit.R` and `round1_joint_audit.py` reproduce baseline `0f609de` and include the old erroneous expressions. Keep their historical outputs separate from current module tests. Shared answer-checking functions now reside in `pmf_helpers.R`.
