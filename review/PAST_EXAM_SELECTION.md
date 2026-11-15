# Optional STATS125 past-exam questions and source materials

Updated on 2026-11-16. Current users are STATS125 students. The main route is concept review followed by visual exploration. Exam extracts are optional and initially collapsed. **The four module question panels use the verified past-exam extracts listed below.**

| Module | Year, semester and original question | Visualisation purpose | Adaptation |
|---|---|---|---|
| Probability Overview | 2026 S1 Q2(a)–(d) | Compare the count model's PMF and CDF, including strict and inclusive inequalities | Original extract with web layout, notation rendering and answer-entry changes. |
| Joint Distribution | 2025 S1 Q3(c)–(d) | Row/column marginal sums and independence | Original table and selected subparts with web layout and answer-entry changes. |
| Conditional Distribution | 2024 S2 Q3(e) | Restrict to a condition, renormalise and read the conditional PMF | Original table and selected subpart with web layout and answer-entry changes. |
| Expectation | 2026 S1 Q3(d), (g) | Connect joint and conditional expectations to tables and plots | Presentation adaptation only. The original piecewise PMF is shown as an equivalent table with explicit zero entries. Variables, numerical data and tasks are preserved. |

The original sources were downloaded into the local STATS125 2026 S2 exam directory. The 2026 S1 final question and solution files came from `2026S1 previous exam scripts`. The 2025 S1 and 2024 S2 files came from `Uploaded Media`. Filenames, one-based PDF pages, SHA-256 fingerprints and question references are in the [source index](evidence/exam_source_index.json).

Initial screening covered question/solution pairs from 2024 S1, 2024 S2, 2025 S1 and 2026 S1. Four groups of subparts were selected from the last three sessions. Their original pages, tables, formulas and reference solutions were checked and independently calculated. Drafts, ambiguous answers and the `very old exams _ not for students` directory were excluded from that selection.

Question wording and numerical data come from the original questions. Web titles, hints, plotting guidance and input feedback support their presentation. Reference solutions were checked and reformatted. Written assumptions and independence arguments require comparison with the reference solution. Automated feedback checks distribution names, numerical fields and selected conclusions.

## Bundled materials and portable loading

On 2026-11-16 the user explicitly requested that the four question groups and their six matching source PDFs be included in the public GitHub repository, so a clone can offer the complete reviewed experience. They are stored in `exam-materials/bank.json` and `exam-materials/pdfs/`. The bank uses paths relative to its own directory. The loader resolves these paths on the receiving computer and verifies the source PDF fingerprints at startup.

Run `Rscript Start-Shiny.R` from the repository root. The launcher installs missing R packages. The bundled bank is discovered from either the repository root or the app directory. `STATS125_EXAM_BANK` remains available as an explicit override, and the earlier `.local/past-exams/bank.json` location remains a fallback. An absent, damaged or fingerprint-mismatched bank yields an empty optional question collection while the core visualisations remain available. The bank and source PDFs stay outside `www/`.

The original 32 project questions remain in internal `legacy` regression coverage. Students cannot select that route. The earlier construction code for 10 original exercises was removed. Generic plot demonstrations and the separate game retain their functions.

## Verification and reproduction

Run `./review/scripts/run_regression.ps1 -ReportPrefix exam` for the module checks. `test_past_exam_bank.R` verifies the available bank and matching PDFs. The older `test_learning_paths.R`, content/layout/concept browser scripts and their 42-question counts describe earlier revisions.

`prepare_past_exam_browser.py` prepares a browser fixture from the bank under `.local/exam-selection/browser_private.js`. Execute that fixture through Playwright CLI `run-code --filename` against the local preview. Temporary CLI output and screenshots remain under the ignored working directories. See the [verification record](evidence/past_exam_verification.md) for the historical results and their limits. Teacher/student evaluation of the teaching experience remains pending.

## Historical storage arrangement

From 2026-11-01 until the explicit publication request on 2026-11-16, the bank and six PDFs were local-only. The bank was held under `.local/past-exams/`, source PDFs on G:, and extracted text, page images and browser fixtures under ignored folders. Earlier reports describe that arrangement. The 2026-11-16 request authorises the selected bundled exam materials. Other local course-reference files and working caches retain their existing storage rules.
