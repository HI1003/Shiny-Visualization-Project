# Optional STATS125 exam verification on 2026-11-01

The user requested past-exam questions only. Four locally verified extracts replaced the optional question panels, retaining concept review, visualisation and initially collapsed questions. See [selection/adaptation](../PAST_EXAM_SELECTION.md) and the metadata-only [source index](exam_source_index.json). This document records the local-only arrangement at that date. Publication of the selected bank/PDFs was subsequently authorised on 2026-11-16.

## Results

| Group | Result | Evidence |
|---|---|---|
| R1-04 original Joint regression | 102/102 | [UI/checking](exam_r1_04_ui.json) |
| R1-05 conditional table | 11/11 | [Outputs](exam_r1_05.json) |
| R1-06 validation, normalisation and shared state | 124/124 | [Modules](exam_r1_06.json) |
| Other numerical, boundary and session fixes | 300/300 | [Modules](exam_remaining.json) |
| New exam bank and actual app | 80/80 | [Exam checks](exam_past_exams.json) |
| Original Joint rational mathematics | 10/10 | [Independent calculations](exam_r1_04_math.json) |
| Selected exam mathematics | 7/7 | [Answer-free summary](exam_independent_math.json) |
| Chrome pages, question/plot loading and layouts | 66/66 | [Browser](exam_browser.json) |
| Image-resource HTTP | 13/13 | [Assets](exam_assets.json) |

Module/interaction checks totalled **537 + 80 = 617/617**. Independent mathematics comprised ten original-bank and seven selected-exam cases. The earlier 695 total included withdrawn original/unverified exercises. Six plot-position/PMF/CDF/caption checks were added after the full run and the exam group rerun to 80/80. Overview preview paragraph containers were then cleaned up and the 80 exam checks and expanded 66-case browser suite rerun. `exam_remaining.json` retains the pre-container-cleanup fingerprint. Current-at-that-stage full R fingerprints are in `exam_past_exams.json`.

## Coverage and fixes

- Default exam entry, year/semester/question/adaptation metadata, all answer fields, two hints and solution, count-once progress, single-question boundaries and retained progress across routes.
- Exact question PMFs loaded into all three table modules. Integer/double coordinate mismatches in example recognition were fixed.
- Two Overview scenarios checked model parameters, selected x, PMF/CDF and explanations, with actual browser loading/submission. Assertions waited for updated outputs and explicitly expanded hidden progress.
- Missing bank, malformed JSON and changed PDF fingerprints disabled questions. Student inputs could not enable legacy, preview/further had no fallback, and the private JSON HTTP route returned 404.
- Four modules at 1600/1266/900/390px showed no page-wide overflow or clipped source/answer labels. Wide/phone screenshots were visually checked and held in ignored folders.

Selected source pages and solutions were compared, with independent rational calculations for tables, marginals, independence, conditional distributions and both expectation directions. Poisson strict-inequality conversion was checked. R source MD5 and six PDF SHA-256 values were rechecked, with PDF MD5 also checked by the loader. Public result summaries omitted numerical exam answers.

## Historical storage, reproduction and limits

At this stage, question text/data/answers, test fixtures and PDFs were local. General loaders/tests, metadata and pass summaries were versioned. Screenshots, raw CLI output, extracted text and build scripts remained excluded, along with .R-library/, .playwright-cli/, .Rhistory, .RData and course-reference directories. Publication reviews checked selected staged files and the complete outgoing history.

Run `./review/scripts/run_regression.ps1 -ReportPrefix exam`. At this historical stage the final group required the local bank/source PDFs and failed explicitly if they were absent, while the visualisation app still ran. Browser fixture preparation is described in the selection record. The original ZIP, old reports and game were retained. Game automated regression passed without a new full manual walkthrough.

This local commit was unpushed and undeployed. Preview stayed at `http://127.0.0.1:7130`, with the earlier 7125 service untouched. A public clone then omitted exam contents, and teacher/student evaluation and another-computer materials handover remained pending.

The verifiable automatic window ended after test/source checking at **14:56:54–15:24:30 NZDT, 27 minutes 36 seconds**, excluding later documentation/exclusion/commit work. Human effort was separately recorded against the historical 15-hour budget.
