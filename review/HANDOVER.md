# Module fixes and STATS125 teaching-review handover

Updated on 2026-11-16. The contract is signed and the user confirmed that no timesheet is required. The user requested an English project and publication of the four selected exam groups and six matching PDFs so the complete reviewed experience can run from a clone. See [exam materials and loading](PAST_EXAM_SELECTION.md). The dated records below retain the storage arrangements and validation scope of each stage.

The 2026-11-14 delivery includes Joint's fraction-labelled heatmap, removal of Joint/Conditional 3D views, matching Conditional table/plot readings and revised layouts. Expectation shows **conditional mean × marginal probability = contribution**, followed by the sum of contributions giving the overall mean, consistent with the table. Overview has numeric inputs synchronised with sliders, short parameter explanations, consistent steps/ticks, adaptive x queries and linked hover/touch readings. Empty question sections are hidden. The expectation flow was committed as `91e5faea07f4a41f169928b1c64cfb6b4e5a6c25` and verified against remote main after push.

## Complete-repository delivery on 2026-11-16

The selected bank and six source PDFs are included under `exam-materials/`. PDF paths are relative to the bank and resolved during loading. The app discovers bundled materials from the repository root or application directory, with explicit environment overrides and the historical local-bank fallback retained. A clone can run the four optional question groups using the standard launcher. Source questions, answers and PDF contents match their previously verified versions.

All 138 versioned text files were scanned for Chinese characters, with none remaining. Comments in the original nested ZIP were also translated. Ten R-expression comparisons confirmed unchanged executable expressions in the four comment-only current files and six archived R files, after removing CSS comments from the comparison. The two translated metadata JSON files retain their numerical structure and fingerprints. Machine-specific Chinese directory strings in course-reference metadata were replaced with source filenames. All six source PDFs contain English extracted text.

Validation passed **861/861** calculation/resource checks, comprising R1-04 102, R1-05 11, R1-06 146, remaining models/app 301, number display 79, continuous queries 104, exam integration 95, independent mathematics 10 and images 13. New loading assertions cover root/app discovery, relocation with spaces, resolved paths, explicit override and missing-source rejection.

A tracked-files-only export in a directory with spaces completed first-run package installation and launched on 7125. It loaded the bundled bank and PDFs from the export. Its separate exam-module run passed **95/95**. Chrome passed exam interaction/loading **93/93**, total-expectation flow **28/28**, game **20/20** and English-interface/layout **21/21**, totalling **162/162**. Selected wide/phone screenshots were visually checked. The clone startup used the configured local R-library environment, and the launcher installed missing packages in the exported project's library.

Publication scope includes only the selected six exam PDFs, the matching bank, English project/review content and supporting loading tests. Local course-reference downloads, dependencies, working caches, raw browser output and screenshots remain under the existing ignored directories. Source PDF MD5/SHA-256 values, bank content equivalence, 211 local documentation links and staged-file exclusions were checked. A complete local ZIP provides the same approved files for direct sharing.

## Delivery review on 2026-11-14

The review covered the launcher, all 15 distributions, three table modules, seven game chapters and local optional exam questions. No delivery-blocking functional issue was found within that coverage. The code was ready for final teacher acceptance. Teacher/student evaluation and formal hosting remained pending.

A tracked-files-only `git archive` export of that commit was created without a bank or installed dependencies. Its `Start-Shiny.R --no-browser` completed first-time dependency installation and launched successfully in Chrome. The environment was Windows and R 4.6.1, with freshly installed Shiny 1.14.0 and Plotly 4.12.1. The export ran on local port 7125, while the original bank-enabled preview ran on 7130.

| Verification | Result and coverage |
|---|---|
| R, independent calculations and assets | 855/855. R1-04 102, R1-05 11, R1-06 146, remaining models/app 301, number display 79, exam integration 89, continuous queries 104, independent mathematics 10, images 13. |
| Launch/navigation without local materials | 16/16. Four learning modules worked, empty question areas/navigation were hidden and the bank HTTP path was inaccessible. Three rapid-navigation rounds recovered correctly. |
| All distribution parameters | 360/360. Fifteen models and 24 parameter pairs, bidirectional updates, manual precision, ranges, integers and linked bounds. |
| Plot queries | Hover/touch 87/87. Continuous same-x PDF/CDF recalculation 157/157. |
| Total expectation flow | 28/28. Both directions, factors matching tables, contribution sums, zero-weight groups, signed contributions, cancellation and narrow-screen approximations. |
| Seven-chapter game | 20/20. Empty input, wrong answers/hints, correct answers/explanations, chapter positioning, ending, restart and phone layout. |
| Local exam version | 93/93 browser checks. Source metadata, answers, table/parameter loading, positioning and progress were checked separately on the original working copy. |
| Light/dark themes and layout | 36/36. Three table modules at 1600px and 390px, page fit, retained theme and visible runtime errors. Desktop/phone screenshots were also visually reviewed. |

Detailed JSON, browser logs, temporary scripts and screenshots are retained under ignored `.local/` and `output/playwright/`. README was corrected to point to the user's repository and explain that the whole current repository ZIP contains the reviewed version. The nested `Project_PPeek1ng.zip` was the original snapshot at that stage.

Teachers still need to confirm course suitability and question selection. Formal hosting depends on the agreed sharing method. The review did not reread every historical course resource or evaluate all operating systems, all browsers or student learning outcomes.

## Historical stage records

**2026-11-12.** The [student-task walkthrough](STUDENT_EXPERIENCE_REVIEW_20261112.md) was completed and six usability issues fixed locally. Further priorities were Joint probability encoding, weighted total expectation, teacher/student trials and a cold-start navigation check. See the [dated summary](evidence/student_experience_20261112.json). Those changes had not been committed or pushed at that time.

**2026-11-10.** The route was concept review → visual exploration → optional past-exam questions. The four question sections were initially collapsed, progress was shown within each module, and module entry used the sidebar.

### Results recorded at those dates

- On 2026-11-10 the sidebar exam-progress summary and Home's two shortcuts were removed. Menus, local progress and feedback remained. Browser checks were adjusted to sidebar navigation. The remote content commit was verified as `ba353d5c058ae0de2d191cf63260888001312845`, followed by a separate documentation commit.
- On 2026-11-10 the Probability table display selector was removed and automatic compact fractions/decimals adopted. Internal format tests retained the format options. These UI changes were synchronised and remained undeployed.
- On 2026-11-04 the sidebar offered Auto / Short decimals / Simple fractions. Tables, formulas and plot labels used compact readings, approximation marks and optional precision details. Editor display preserved unchanged values. Commit `ecef62163f4f4e74c99c989bbe6d4430c84ae26d` was synchronised with a matching remote SHA. See the [verification](evidence/number_display_verification.md) and [work log](WORKLOG.md).
- R1-01–R1-11, R2-01–R2-07 and earlier teaching/layout work had been synchronised, with record commit `5063d1d`. Concept-first `2eed4f9` and exam revision `b94764d` were synchronised on 2026-11-01, with remote content SHA `b94764d412ad16f6420b37092b09243869bf8e36`. Subsequent documentation commits are recorded in Git history.
- The four question panels contained four STATS125 groups checked against local papers and solutions. See [selection](PAST_EXAM_SELECTION.md). No original exercise was added in that round.
- The earlier 10 original exercise builders were removed. The original 32 questions remained internal legacy regression material. Historical 30/8/4, 42-question and 695/695 records refer to earlier versions. Generic demonstrations and the game remained available.
- The expectation extract converted a piecewise PMF to an equivalent table and disclosed the presentation adaptation. Other extracts changed layout, notation and answer entry. Written reasoning was checked by comparison with the reference solution, while automated checks assessed fields.
- At that historical stage, the bank was held in `.local/past-exams/bank.json` and checked against G: PDFs. Missing materials left the visualisations available and the question collection empty. A code-only clone then omitted the exam contents.

### Historical verification and evidence

The 2026-11-10 UI checks passed 80/80 module/app and 66/66 browser cases (`local_progress_*`), with matching MD5 values for 11 app R files. Earlier `auto_display_*` checks passed 72/72 and 29/29. The 19/19 layout result belonged to the `d2dc5da` / `ff8c390` stage. Each evidence file retains its original fingerprint.

The earlier [number-display suite](evidence/number_display_verification.md) passed 689/689 module/precision checks, 29/29 browser checks, 10/10 independent mathematics and 13/13 images, including reruns of R1-04/05/06 and exam integration. See the [exam verification](evidence/past_exam_verification.md). Earlier learning-path/content/layout/concept scripts remain historical.

The recorded command was `./review/scripts/run_regression.ps1 -ReportPrefix numbers`. The exam group needed the local bank and PDFs at that stage. Asset checks used `./review/scripts/test_assets.ps1 -BaseUrl http://127.0.0.1:7130`. Browser number-display checks used `check_number_display_browser.js`, with exam fixture preparation described in the selection record.

### Follow-up recorded at that stage

1. Experience the concept and plot sequence, and optionally expand **3. Optional past-exam questions** to check the four groups and their sources.
2. Obtain teacher feedback on selection and presentation, and arrange materials for another computer when required.
3. Review every outgoing file/version and verify the remote SHA after synchronising. That review covered 56 paths and 66 file versions, including 65 unique contents.
4. Collect trial feedback and agree the sharing/hosting arrangement. The later user clarification removed the timesheet task.

### Scope and local storage

The app supports selected STATS125 topics. Conditional expectation, total expectation and discrete E[g(X)] remain core. The reviewed STATS210 coursebook was the downloaded 2024 edition.

During those rounds, source PDFs were in `G:\STATS`, private bank/text/page images and scripts in `.local/`, dependencies in `.R-library/`, browser screenshots in `output/playwright/` and browser state in `.playwright-cli/`. The preview was on local 7130. Publication of the selected six PDFs and bank was subsequently authorised on 2026-11-16.
