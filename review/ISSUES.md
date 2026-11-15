# First-round issue register

**2026-11-16 update.** The user requested English documentation/comments and distribution of the selected exam bank and six source PDFs with the public repository. Current loading is described in [PAST_EXAM_SELECTION.md](PAST_EXAM_SELECTION.md).

**2026-11-14 update.** The student-task findings concerning probability encoding, total expectation, collapsed editors, overlapping paths and empty exam sections have corresponding improvements. Joint/Conditional 3D views were removed. Expectation uses a table-matched multiplication/addition flow. A tracked-files-only export completed installation, launch and Chrome checks. Three rapid-navigation rounds recovered correctly. See the [handover](HANDOVER.md). Teacher/student acceptance remains pending. Dated observations below retain their original scope.

**2026-11-12.** [Student review](STUDENT_EXPERIENCE_REVIEW_20261112.md) added UX-01–UX-06, fixed locally, including exam-to-plot positioning, retained conditioning direction, empty game submission, chapter positioning and contrast. Further recommendations concerned probability encoding, total expectation, collapsed editors, path definitions and static solution formatting. Cold-start timing still required independent confirmation. That round was uncommitted/unpushed at the time.

**2026-11-04.** Display improvements appear in FMT-01–FMT-05 and [number-display verification](evidence/number_display_verification.md).

First audit dated 2026-10-21 against `0f609de`. By 2026-10-30 **R1-01–R1-11 were fixed and verified**, with seven additional R2 groups. Git history identifies the fix commits. P1 affects teaching correctness, checking or core calculations. P2 concerns boundaries, usability or wording. Evidence codes are **B** browser, **R** executable calculation, **S** source inspection and **C** local course reference. Original line numbers refer to the audit baseline.

| ID | Priority | Module | Issue and status | Evidence |
|---|---|---|---|---|
| R1-01 | P1 | Conditional | Incorrect Q4 Poisson/Q10 Normal answers, fixed and verified | B/R/S/C |
| R1-02 | P1 | Expectation | Q4 exact fraction rejected, fixed and verified | B/R/S/C |
| R1-03 | P1 | Conditional | Substring distribution-name matching accepts wrong models, fixed and verified | B/R/S/C |
| R1-04 | P1 | Joint | Eight of ten tables/answers inconsistent, fixed and verified | B/R/S/C |
| R1-05 | P1 | Conditional | Default table repeats its first entry and exceeds mass 1, fixed and verified | B/R/S/C |
| R1-06 | P1 | Joint/Conditional/Expectation | Missing validation and inconsistent normalised displays, fixed and verified | B/R/S/C |
| R1-07 | P1 | Conditional | Attempt-count Geometric convention not connected to course convention, fixed and verified | S/C |
| R1-08 | P1 | Expectation | Q8 requests two means but checks one value, fixed and verified | R/S/C |
| R1-09 | P2 | Overview | p=1 silently replaced by .999, fixed and verified | R/S/C |
| R1-10 | P2 | Conditional/Overview | Overlapping tables and continuous point-probability instructions, fixed and verified | B/S/C |
| R1-11 | P2 | Game | Discrete Uniform equal-probability/sampling explanations, fixed and verified | B/S/C |

## R1-01, two conditional-bank numerical errors

- Original locations were `module_conditional.R:852` for Q4 and `:1143` for Q10, including associated hints/solutions.
- Q4 rejected `0.347229417554172` and stored `0.263`. The correct reference is `ppois(10,12)=0.347229417554172`.
- Q10 states that 9 in `N(65,9)` is the variance, so `P(Y>70)=pnorm(70,65,3,lower.tail=FALSE)=0.047790352272815`. Its stored `0.0475` exceeded the `1e-4` tolerance.
- C125 p92 and C210 continuous distributions support the checks. See [numerical evidence](evidence/round1_numeric.json). Q10 was checked in source/R, without a browser submission at that stage.
- Acceptance required unrounded reference values, consistent question/hint/solution text, acceptance of permitted four/five-place readings and rejection of old wrong values.

On 2026-10-30 Q4 stored full-precision `ppois(10,12)` and displayed approximately .3472 (34.72%). Q10 used sd=3 and z=5/3, displaying approximately .0478. The old .263/.0475 were rejected. Q8/Q12 retained their displayed approximations with full-precision checking references. **Fixed/verified, teacher review pending.** See [final verification](evidence/final_verification.md) and commit `Fix remaining course audit issues and session isolation`.

## R1-02, exact Uniform second moment rejected

Original locations were `module_expectation.R:720` and checker `:70`. Q4 rejected `10000/3`, although fractions were allowed. `E[X²]=∫[0,100]x²/100 dx=10000/3`, while the stored 3333.33 differed beyond the general `1e-4` tolerance. References are C210 p106/p169 and [numerical evidence](evidence/round1_numeric.json).

The 2026-10-30 fix stored `10000/3` and explicitly allowed exact fractions or two-place decimals. Only this question used absolute tolerance .005. `10000/3`, 3333.3333333333 and 3333.33 pass, while 3333.34/3333.32 fail. Other questions retain 1e-4. **Fixed/verified, teacher review pending**, with examples in [final verification](evidence/final_verification.md).

## R1-03, distribution-name false positives

The original checker after `module_conditional.R:1370` used `grepl(correct_text,user_input,...)`. Q1 accepted Negative Binomial with success feedback. R also confirmed acceptance of `not Binomial`. The target was Binomial(x,0.2).

The 2026-10-30 shared checker matches complete normalised names against controlled aliases. Name-only input remains explicitly allowed, with case variants, a distribution suffix, bin/binom and Gaussian accepted where applicable. Wrong models, negations, unrelated appended text and empty inputs fail. **Fixed/verified, teacher review pending**, in [final verification](evidence/final_verification.md).

## R1-04, joint tables, answers and explanations

Original location `module_joint.R:574`, `get_joint_question_bank()`. See independent [rational calculations](evidence/round1_joint.json).

| Question | Original table/event result | Stored answer | Finding |
|---|---|---|---|
| Q1 | Total 17/24 | Target 1/8 | Target matches, table invalid |
| Q2 | Total 4/5 | Target 1/20 | Table invalid |
| Q3 | Total 17/18 | Marginal 7/18 | Table invalid |
| Q4 | Total 7/12, target sum 7/24 | 1/4 | Table and answer inconsistent |
| Q5 | Four-cell event 1/2 | 2/5 | Valid table, wrong answer |
| Q6 | Three-cell event 5/12 | 7/24 | Valid table, wrong answer |
| Q7 | Known sum 23/24, missing 1/24 | 1/8 | Stored answer gives total 13/12 |
| Q8 | Known sum 1, 2a=0 | 1/10 | Stored answer gives total 6/5 |
| Q9 | Coefficient sum 18, k=1/18 | 1/18 | Numerical check passes |
| Q10 | Known sum 2/3, 3p=1/3 | 1/9 | Numerical check passes |

C125 p52/p95–96 requires legal PMFs before marginal/event calculations. Acceptance covers nonnegativity, mass 1, shared table/answer data, zero cells, boundaries and missing parameters.

The 2026-10-30 fix defined all ten questions using integer weights/denominators and generated tables, target cells, reduced answers, two hints and solutions from the same data. Non-target changes were Q1 (2,0) 1/24→1/3, Q2 (0,0) 1/10→3/10, Q3 (0,0) 1/9→1/6, Q4 (0,1) 1/24→11/24. Q5–Q10 retained their table/parameter forms, with Q10's marginal question marks excluded from joint mass.

Correct Q1–Q10 answers are **1/8, 1/20, 7/18, 7/24, 1/2, 5/12, 1/24, 0, 1/18, 1/9**. Q8 states a≥0, and the checker rejects negative input before tolerance comparison. Independent mathematics improved **2/10→10/10**, module interaction **92/102→102/102**. Browser checks accepted Q5 1/2, rejected Q8 .1, accepted Q8 0 and confirmed Q1's changed table after reload. R1-05 reran **11/11**, R1-06 **124/124**. See [verification](evidence/r1_04_verification.md). **Fixed/verified, teacher review pending.** Local commit `Fix R1-04 joint probability question bank consistency` was unpushed/undeployed at that stage. Other bank/layout/session work remained separate.

## R1-05, first probability repeated

Original locations `module_conditional.R:518` and `:526`. Default `f(Y|X=0)` showed .92157 twice, total 1.84313. Expected values are 188/204=47/51≈.92157 and 16/204=4/51≈.07843. Scalar-test `ifelse(total_x>0,p_value/total_x,0)` returned one value that mutate recycled. Plots used vector division. C125 p114 was visually checked.

The 2026-10-30 fix validates the scalar marginal, then divides each cell. Nonpositive/nonfinite marginals produce undefined validation. Actual table/3D/bird's-eye output tests improved **0/11→11/11**, covering both default directions/values, all five nonuniform 2×3 slices and zero marginals in both directions. Browser readings were .92157/.07843 and .94124/.05876 for Y=1, with total 1.00000. See [verification](evidence/r1_05_verification.md) and [results](evidence/r1_05_regression.json). **Fixed/verified, teacher review pending.** Local commit `Fix R1-05 conditional probability table normalization` was unpushed/undeployed, with R1-06/R1-10 still open at that point.

## R1-06, invalid probabilities and inconsistent normalisation

Original locations included Joint :24/:388/:435, Conditional Generate around :402 and Expectation :408. Input -1,1,1,1 generated -.5,.5,.5,.5 while cells retained original input strings. All-zero totals produced NaN and unparseable strings could propagate NA. C125 p52 requires nonnegativity and mass 1. See [browser evidence](evidence/round1_browser.md).

The 2026-10-30 shared pmf_helpers.R implementation accepts finite nonnegative values, rejects empty/unparseable/nonfinite/zero-denominator/all-zero data and retains committed results after failures. Generate validates each row, merges duplicates, scales large weights, normalises and updates text/values with fresh IDs. Normalize/Uniform edit drafts, and Generate commits. Add Row recovers empty tables. Three modules share committed state within a session.

Results were **124/124**, comprising 40 per module and four synchronisation cases. Browser checks covered negative rejection, valid normalisation, cross-module readings and retained expectations after all-zero input. R1-05 reran **11/11**, with its original assertions retained and shared helpers added to setup. See [verification](evidence/r1_06_verification.md), [results](evidence/r1_06_regression.json) and [R1-05 rerun](evidence/r1_05_after_r1_06.json). **Fixed/verified, teacher review pending.** Local commit `Fix R1-06 PMF input validation and normalization` was unpushed/undeployed. Question banks, checking rules and multi-session isolation were outside that patch.

## R1-07, Geometric conventions

Original Conditional Q5/Q6 near :904/:945 defined attempts Y including the first success and used P(Y≥3)=(1-p)²=.64. That arithmetic is valid for support starting at 1. C125 p79 and Overview use failures before success, starting at 0, with dgeom and mean (1-p)/p.

The 2026-10-30 fix asks Q5 for Z=Y−1 and states its zero-based support throughout. Q6 retains attempts Y, P(Y≥3)=.8²=.64 and the shift to Z. Changing only .64 to .512 would change the event. **Fixed/verified, teacher review pending**, in [final verification](evidence/final_verification.md).

## R1-08, two requested answers with one checked field

Expectation Q8 near :881/:887 asks for Sunny and Cloudy means (24,12), but originally stored ans_val=24, accepted 24 alone and rejected paired input. C125 p92 and the numerical review support both means. The 2026-10-30 fix adds two labelled fields and requires both correct, accepting equivalent fractions and giving targeted feedback for missing/swapped/wrong values. **Fixed/verified, teacher review pending**, in [final verification](evidence/final_verification.md).

## R1-09, valid endpoint silently replaced

Overview originally allowed p=1 but capped it at .999 near :74/:78/:240/:248/:311/:318. R source evaluation gave Geometric P(X=0)=.999 and mean .001001..., Negative Binomial k=2 mass .998001 and mean .002002..., instead of mass 1 at zero and mean 0. This endpoint was source/R checked in the first round.

The 2026-10-30 fix removes the cap and supports the degenerate distribution. Checks used .01/.5/.99/1. Unbounded discrete plots start at 0 and extend to the .999 quantile with readable ticks. **Fixed/verified, teacher review pending**, in [final verification](evidence/final_verification.md).

## R1-10, instructions and layout

At about 1521px the Conditional selector overlapped the joint table/marginal, near the original nested-column layout around :485. Overview's continuous mode retained “display P(X=x)” instructions although it should show f(x)/F(x), with P(X=x)=0 as in C210 p105.

The 2026-10-30 fix introduces wrapping table/calculation regions, wrapping rows and card-local formula/table scrolling. Browser checks used 1266×800 and 900×800. Continuous mode explicitly identifies density, CDF and zero point probability. **Fixed/verified, teacher review pending**, with that viewport coverage in [final verification](evidence/final_verification.md).

## R1-11, Discrete Uniform modelling assumptions

The game chapter 2, originally near :132–151, inferred “must be equally likely” from absent clues and made a general claim about changing success probabilities under repeated DU sampling. Equal probability must be an explicit assumption. Independent sampling with replacement can have constant success probability, while searching without replacement changes conditional probabilities. C125 p91's definition and specific example do not imply the broader claim.

The 2026-10-30 fix states the simplifying assumption in the story, explanation and summary, and distinguishes the sampling mechanisms. Additional game assumptions appear in R2-03. **Fixed/verified, teacher review pending**, in [final verification](evidence/final_verification.md).

## Additional confirmed fixes

| ID | Priority | Change | Verification |
|---|---|---|---|
| R2-01 | P1 | Create PMF state inside each server session and pass it explicitly to modules | Two simultaneously live app-server mock sessions and two browser tabs update independently, with within-session regression retained |
| R2-02 | P2 | Reject Uniform a=b with recovery, preserve mathematical infinite densities while omitting sampled endpoints, limit Gamma integer-shape explanation and add t/F independence conditions | Typical parameters for seven discrete/eight continuous models, valid endpoints, invalid-range recovery and four singular endpoints |
| R2-03 | P1 | Replace fixed-five-of-ten warehouse story with ten independent p=.5 warehouses and unknown total. Hypergeometric states N=7/M=1 and fixed n=4. Poisson/Geometric assumptions explicit. | All seven chapters' correct/wrong feedback and transitions, complete browser path with 21 points, definition checks |
| R2-04 | P2 | Register game once, reset state/scores/feedback and prevent old chapter controls affecting the current one | Seven chapters' hints/scoring, three restart rounds and browser restart |
| R2-05 | P2 | Undefined zero-marginal means, readable tiny positive values | Both directions, 2e-8 denominators and 1e-14 probabilities |
| R2-06 | P2 | Add standard app.R and launch the directory so www assets are served | Local launch, all 13 images HTTP 200/image MIME and visible browser loading |
| R2-07 | P2 | Readable dark headers and retained manual theme during navigation | Actual headers/titles/backgrounds, module changes and return to light |

All were **fixed/verified, teacher review pending**. See [final verification](evidence/final_verification.md).

## Follow-up verification scope

| ID | Evidence and limits |
|---|---|
| F1 | R2-01 verified two-session isolation, with production multi-user load testing pending |
| F2 | Within-session synchronisation, separate drafts/commits and retained valid results remained covered by 124 checks |
| F3 | Specified parameter/endpoint matrix covered invalid Uniform bounds, singular densities and discrete tails. Finite sampled sharp peaks remain visually limited on linear axes. |
| F4 | Seven chapters/restart, server plot selection, browser themes/layouts were checked. Full keyboard/screen-reader coverage and every input combination remained outside that run. |

Teachers retain responsibility for course suitability, scenario preferences and classroom use.

## STATS125 teaching review on 2026-10-31

The user identified current STATS125 students as the audience, with STATS210 later. T125 items track teaching improvements separately from the fixed R1/R2 issues.

| ID | Work | Status at that stage |
|---|---|---|
| T125-01 | Default core and optional preview/further paths | Implemented/verified 30/8/4 with separate filtering/navigation/counts, including transient switching fix |
| T125-02 | CDF endpoints, table conditioning, independence and total-expectation practice | Eight proposals implemented as O01, J11–13, C14–15 and E10–11, requiring all fields correct |
| T125-03 | Support, parameters and assumptions in model questions, including discrete Hypergeometric/Negative Binomial | C16–17 added name/parameter/mean checking and stated assumptions/support, while older name-question rules remained |
| T125-04 | Discrete settings for transformed expectation/variance | E10–11 cover total expectation, E[XY], E[Z²], squared mean and variance |
| T125-05 | Prerequisites, notation/units and a running example | Home prerequisites/glossary, chapter cues and fictional frequency example implemented, teacher trial pending |
| T125-06 | Learning order for game/visualisation | Home order, practice-first layout, 2D priority and collapsed 3D implemented at that stage, story order retained |
| T125-07 | Shepherd story direction, approximation signs, Uniform interval explanation and positive Gamma shape | Wording fixed, original 32 answer fields retained, 300/300 regression |
| T125-08 | Context for default 188/221 fractions | Cards explanation, 20 observations, zero-marginal presets and custom variable/unit cues implemented |
| T125-09 | Plot controls unable to represent question parameters | Fifteen presets with matching x, λ≤30, μ∈[-100,100], Uniform b≤200 |

See [teaching review](TEACHING_REVIEW_STATS125.md), [initial scope evidence](evidence/teaching_scope_2026_10_31.json) and [implementation verification](evidence/content_verification.md). Teacher/student acceptance remained pending.

## Access and layout review on 2026-10-31

U1-01–U1-07 addressed narrow theory, hidden practice access, an empty Joint column, responsive main content, control/sidebar wrapping, zero-width hidden formulas and Overview sections. All were fixed/verified. Results were layout 77/77, student flow 22/22, modules 695/695 and independent mathematics 10/10. See [layout verification](evidence/layout_verification.md). Historical R1/R2/content evidence was retained.

## Learning-route feedback on 2026-11-01

The user prioritised concept review and visual understanding because students already have quizzes/assignments. Four modules moved to review → explore → optional self-checks, with concise concepts/prompts and collapsed practice/progress. Ten new exercises were identified as originals and original-project provenance remained unverified. That stage added no past exams. Results were modules 695/695, concept-first browser 65/65 and optional practice 22/22. See [record](evidence/concept_first_verification.md). Previous practice-first records remain historical.

## Verified exam extracts on 2026-11-01

| ID | Work | Status |
|---|---|---|
| EXAM-01 | Select original questions fitting the visualisations | Four groups, 2026 S1 Q2(a)–(d), 2025 S1 Q3(c)–(d), 2024 S2 Q3(e), 2026 S1 Q3(d), (g) |
| EXAM-02 | Year/semester/question/PDF pages/source/adaptation labels | Implemented, with equivalent PMF presentation for Expectation and manual review of written arguments |
| EXAM-03 | Remove original/unverified exercises from student panels | Ten original builders removed, 32 retained internally, no fallback when bank missing |
| EXAM-04 | Questions linked to their tables/parameters | Original table/scenario loading, concept-first/collapsed entry and route isolation |
| EXAM-05 | Exclude course contents and working caches at that stage | PDFs, bank, build scripts, extracted text, page images, raw CLI and exam screenshots stayed local |
| TEST-EXAM-01 | Loading/checking, browser, independent calculations and R1-04/05/06 | [Latest exam verification](evidence/past_exam_verification.md), with older 695/42 records preserved |

Teacher/student trials, deployment and another-computer materials handover remained future work at that stage. See [selection](PAST_EXAM_SELECTION.md) and [verification](evidence/past_exam_verification.md).

## Probability formatting on 2026-11-04

| ID | Issue/work | Result at that stage |
|---|---|---|
| FMT-01 | Long normalised decimals in editors/tables | Separate full values and compact displays, preserving original precision for untouched bindings |
| FMT-02 | Inconsistent fractions/decimals across tables/formulas | Shared Auto / Short decimals / Simple fractions formatting without changing probabilities or checker values |
| FMT-03 | Decimal places, trailing zeros and approximation signs | At most four ordinary decimal places, no trailing zeros and ≈ in approximate cells/steps, with static original questions unchanged |
| FMT-04 | Tiny nonzero values and half-rounding boundaries display as zero | Scientific notation for tiny/boundary values, including .00005, with negative validation retained |
| FMT-05 | Detailed values after compact formatting | Precision tooltips, Overview More precision and six-place Plotly readings |

The local 2026 STATS125 coursebook p97/113/114/119/148 uses fractions and short decimals and suggests consistency in comparisons. Four places and denominator bounds were app choices. See [number-display verification](evidence/number_display_verification.md). Source pages, bank contents and browser caches were excluded at that date.
