# Probability display and computational precision on 2026-11-04

The user reported excessive decimal places. This round checked the local STATS125 2026 coursebook and aligned interactive tables, editors, conditional probabilities, expectation formulas and Overview readings.

## Display rules and course basis

Coursebook p97 uses short decimals, p114/119 retain fractions, p113 discusses using consistent forms for comparisons, and p148 includes exact and decimal readings. Pages were rendered and their PDF fingerprint checked against the index. Four decimal places and the simple-fraction denominator bound are app display choices. PDFs, rendered pages and extracted text remained on G: or in ignored `.local/`.

- Sidebar **Probability table display** offered Auto / Short decimals / Simple fractions, shared by Joint, Conditional and Expectation. Formatting left draft/committed probabilities and completion counts intact.
- Auto used short decimals and recoverable simple fractions. Simple fractions required denominator ≤500 and machine-precision agreement. Other values used short decimals.
- Ordinary approximate values used at most four decimal places without trailing zeros. True 0/1 stayed integers. Values that would otherwise display as zero used scientific notation, including the `0.00005` half-rounding boundary. Approximate cells and calculation steps used `≈`.
- Tables, editors and expectations exposed full precision on hover. Plotly added six-place readings. Overview offered four-place readings and expandable **More precision**. Density, probability and coordinates retained their correct labels.
- Static source questions/tables/solutions and the private bank retained their wording and values at this stage. Interactive formatting was separate. The game and persistent grading were outside this round.

## Preserving original values

`pmf_prepare()` retained round-trippable input strings, but displaying them directly produced long decimals. The revised editor generated compact text while keeping full-precision `p_input`/`p_value`. An unchanged displayed entry retained its original value, while a genuinely edited entry was parsed anew. Normalisation, validation, shared state and fresh control IDs retained their existing roles.

Coverage included module/format changes, repeated Generate, Normalize followed by Generate, empty/negative input and approximate editor labels. The UI explained that unchanged entries retain precision.

## Verification

| Group | Result | Evidence |
|---|---|---|
| R1-04 original Joint bank | 102/102 | [Interactions](numbers_r1_04_ui.json) |
| R1-05 conditional tables/plots | 11/11 | [Outputs](numbers_r1_05.json) |
| R1-06 validation, normalisation, draft/commit and shared state | 124/124 | [Modules](numbers_r1_06.json) |
| Other calculations, boundaries, sessions and game | 300/300 | [Regression](numbers_remaining.json) |
| Verified local exam bank and app | 80/80 | [Exam regression](numbers_past_exams.json) |
| Number display and precision preservation | 72/72 | [Precision](numbers_precision.json) |
| Independent rational checks | 10/10 | [Mathematics](numbers_r1_04_math.json) |
| Chrome formatting, actual inputs and layouts | 29/29 | [Browser](numbers_browser.json) |
| Image resources | 13/13 | [HTTP](numbers_assets.json) |

Module/interaction checks totalled **689/689**, comprising 537 original, 80 exam and 72 display checks. `./review/scripts/run_regression.ps1 -ReportPrefix numbers` passed with the display group added. At this stage the exam group required local bank/PDFs.

R1-05/R1-06 separately read complete cell values and visible labels, retaining probability, normalisation and plot precision checks. Additional assertions checked display error, editor text and full-precision information. Five/six-place string expectations were updated to the new display rules. Tiny positive denominators used nonzero scientific notation, while zero denominators remained invalid.

Synthetic fixtures tested eight repeated generations per module, actual edits, Normalize/Generate, negative rejection, format/data separation, integers/fractions, tiny values and half-rounding boundaries. Chrome checked actual editing/repeated generation, shared formats and 1600/1266/900/390px input/label/page bounds. Long formulas retained existing scrolling containers.

Wide/phone screenshots were visually checked and kept in ignored output/playwright/. General code, tests and content-free summaries were recorded. Original historical reports remained separate, with this run's source fingerprints retained in its results.

## Status and timing at that stage

The revised preview was `http://127.0.0.1:7130`, with browser refresh required. Only the task-owned preview process was restarted, and the independent validation browser was closed afterward.

Local commit title `Use compact probability displays without losing precision`, SHA in Git history, unpushed and undeployed at this stage. Earlier main synchronisation at `a3a195c` remained recorded. Teacher/student experience feedback was pending.

The verifiable automatic window was **11:35:21–11:49:44 NZDT, 14 minutes 23 seconds**, excluding prior reading/design and later documentation/index/commit work. Human time remained separately recorded against the historical 15-hour budget.
