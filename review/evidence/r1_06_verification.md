# R1-06 fix verification

Date 2026-10-30, Pacific/Auckland. Before-fix baseline `491c137`. **Fixed and verified, awaiting teacher review.** Local commit title `Fix R1-06 PMF input validation and normalization`, unpushed and undeployed at that stage.

## Changes and behaviour

- `modules/pmf_helpers.R` shares parsing, validation and the three button actions. `main.R` loads it before Joint, Conditional and Expectation.
- Finite nonnegative decimal, scientific and fractional inputs are accepted as probabilities or relative weights. Empty, unparseable, negative, zero-denominator, nonfinite and zero-total inputs are rejected. Each row is checked before merging duplicate coordinates. Coordinates must also be finite.
- Feedback identifies the invalid row. Failed operations retain the last committed PMF for plots, marginals, conditional probabilities and expectations.
- Generate merges duplicate coordinates, normalises and updates both text and numerical values. Calculations retain their precision. Tiny negatives cannot round to zero before validation. Large weights are scaled before summation to prevent overflow.
- Normalize changes the draft. Uniform replaces existing draft-row weights with equal weights and can recover invalid p entries. Generate commits. Add Row remains available for an empty table. IDs increase monotonically, including after rebuilding controls, to prevent stale bindings from overwriting results.
- The three modules synchronise committed data within a session. Multi-session isolation remained the separate F1 follow-up at that stage.

## Before-fix reproduction

Each actual baseline module accepted `-1,1,1,1` and generated `-.5,.5,.5,.5`, while cells displayed the original inputs. See the [before-fix evidence](r1_06_before.json), comprising those three reproductions.

## Module and integration verification

[test_r1_06.R](../scripts/test_r1_06.R) runs actual Shiny modules through testServer. **124/124 pass**, with [results and source MD5](r1_06_regression.json).

| Category | Checks |
|---|---|
| Forty per module | Generate/Normalize rejection of 11 invalid-input classes, empty-table controls, recovery, six valid datasets, draft/commit behaviour and deletion/recreation of rows |
| Invalid inputs | Negative, tiny negative, abc, 1/0, 0/0, empty string, Inf, NaN, overflow, incomplete fraction and all zero |
| Valid data | Weights 1/2/3/4, fractions, millionth-scale values, four 1e308 weights, duplicates and zero cells with positive total |
| Downstream consistency | Input text and values, complete joint table and marginals, Joint 3D, Conditional plot and both unconditional expectations |
| Four synchronisation cases | Joint commit updates all three views, invalid Conditional Generate preserves all views, invalid Expectation Normalize preserves all views, valid Expectation commit updates all views |

Invalid operations retained the complete previous PMF/table and produced feedback. Fraction display used its prior precision, allowing a display error of 0.000011, while internal totals and plots used tighter floating-point tolerances. Input text round-tripped to the same numerical value.

The original R1-05 scenarios and expectations passed **11/11** in the [rerun](r1_05_after_r1_06.json). Its script additionally loaded the shared helper and retained the five-place comparison fixture. Historical evidence remained separate.

Run from the repository root.

```powershell
& 'C:Program FilesRR-4.6.1indRscript.exe' --vanilla review/scripts/test_r1_06.R
& 'C:Program FilesRR-4.6.1indRscript.exe' --vanilla review/scripts/test_r1_05.R review/evidence/r1_05_after_r1_06.json
```

Existing R 4.6.1/Shiny dependencies were used. Locale warnings did not stop execution. Reports contain source MD5 values. Course files and caches remained under local ignored directories.

## Browser verification

1. Joint rejected `-1,1,1,1` with Row 1 feedback, retaining the four-fraction table and plot.
2. Joint generated `1,2,3,4` as `.1,.2,.3,.4` in inputs and table, with marginals (.3,.7) and (.4,.6).
3. Conditional received those values and showed default `Y|X=0` as `.33333,.66667`, total `1.00000`.
4. Expectation showed `E[X]=.7`, `E[Y]=.6`. All-zero input produced positive-total feedback and retained those expectations.
5. Valid `.1,.2,.3,.4` data was restored after testing.

![Negative input rejected while retaining the valid table](r1_06_invalid.jpg)

![Normalised weights and marginals](r1_06_normalized.jpg)

Other boundaries, duplicate coordinates and deleting all rows were covered by module tests. R1-10 layout work remained separate. The three legacy question banks and answer rules retained their previous contents. Nine audit issues remained at this stage.
