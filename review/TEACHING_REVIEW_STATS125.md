# STATS125 teaching review and implementation

**Current exam-only revision.** The four student question panels use four verified STATS125 exam groups. The ten earlier original exercise builders were removed, and the original 32 remain internal regression material. Generic demonstrations and the game remain. The 42-question classification and original proposals below preserve the earlier development record. Current selection is in [PAST_EXAM_SELECTION.md](PAST_EXAM_SELECTION.md).

**2026-11-01 update.** The user prioritised concept review → visual understanding → optional self-checks. Concepts/prompts initially appeared, with practice at the end and collapsed. At that earlier stage ten questions were identified as originals and the original 32 had unverified exam provenance. See [concept-first verification](evidence/concept_first_verification.md).

The course-scope review was dated **2026-10-31**, Pacific/Auckland, against `eabd184`. The intended users were current STATS125 students, with STATS210 later and a small optional preview of useful foundations.

After the initial review/wording fixes, historical content work implemented a default core route, separate preview/further paths and progress, ten added core questions and question-to-table/plot loading. Totals were **30 core, 8 preview and 4 further exploration**, pending teacher/student acceptance.

## Teaching scope

The app supports selected topics in STATS125 Chapters 5–8, including discrete PMF/CDF, distributions, joint/conditional distributions and expectations. **Conditional expectation, total expectation and E[g(X)] remain STATS125 core.** C125 Chapter 5 p60–68, Chapter 8 p136–149 and 2026 S2 Tutorial 8 support that scope. Discrete examples introduce these concepts before optional Normal/Exponential prerequisites.

The original 32 were classified as **20 core, 8 preview and 4 further**. Ten original additions were all core, addressing CDF inequalities, conditioning tables, independence, transformed expectation and total expectation. These classifications describe the app's learning sequence.

## Course evidence

| Source | Review use |
|---|---|
| C125, 2026 gapped book, 205 pages | Contents and Chapters 5–8 definitions/formulas/objectives, p136 conditional means, p138/p146 total expectation, p145 conditional expectation as a random variable |
| C125-T4, 2026 S2 Tutorial 4 | CDF validity/endpoints/inequalities and relations among PMF/CDF/mean/variance |
| C125-T6, Tutorial 6 | Joint/marginal tables, E[XY] and independence |
| C125-T7, Tutorial 7 | Both conditional-PMF directions, discrete models, parameters and assumptions |
| C125-T8, Tutorial 8 | Conditional/total expectation, discrete transformations, correlation and independence |
| C125-TINFO / C125-FORM | Test information/formulas and notation. A Chapters 2–6 mid-semester test scope applies to that assessment. |
| C210, downloaded 2024 gapped book, 235 pages | Density/expectation p94–108, Uniform p169, Exponential from p170, Gamma from p177 and Normal from p183, for optional later-study context |

C125/C210 correspond to STATS125/STATS210 IDs in the evidence. All eight selected PDFs' SHA-256 values were checked. Rendered-page review covered C125 p3/136/146, C210 p3 and Tutorial 4/7/8 p1. Other selected topics used text/formula inspection. Full downloaded directories and all historical papers were outside this review. The 2024 book identifies its own version.

Metadata, the original 32-question catalogue and exact original-example results are in [teaching_scope_2026_10_31.json](evidence/teaching_scope_2026_10_31.json). At this stage source PDFs, text extracts, rendered pages and temporary scripts stayed local.

## Learning levels

| Level | Content | Student task | Presentation |
|---|---|---|---|
| STATS125 foundations | PMF, CDF, E[X], E[g(X)], Var(X), seven discrete models | Define variable/support/assumptions/parameters, read plots/tables and interpret calculations | Default route with chapter cues, then the model-choice game |
| Later STATS125 core | Joint/marginal distributions, independence, conditional PMFs/means and total expectation | Restrict and renormalise, distinguish directions and weight conditional means | Prerequisites linked to Chapters 7–8 |
| Optional preview | Continuous Uniform/Exponential/Normal intuition | Density versus probability, area, waiting times, location/scale | Voluntary route with necessary concepts/formulas |
| Further exploration | Gamma/Beta/χ²/t/F, integration for moments, Normal standardisation/tails | Further continuous-distribution methods | Optional exploration |

Gamma appears in the STATS210 book, but was not required as an initial preview for current STATS125 students. Beta is labelled non-examinable in that book at p182. χ²/t occur in later relationships/inference. F was not verified as necessary preview material. Suggested labels were `STATS125 Core`, `Optional preview for later STATS210 study` and `Further exploration`.

## Original question-by-question review

J/C/E denote Joint/Conditional/Expectation. The 32 questions exclude game chapters and distribution plots. Metadata/filtering was proposed while preserving question IDs/answers and existing regression evidence.

| ID | Main objective | Level | Basis and treatment |
|---|---|---|---|
| J01 | Read a joint cell | Core | C125:95-105. Retain a progression from cells to marginals/events/validity, checking table orientation. |
| J02 | Read a joint cell | Core | C125:95-105. Same progression and orientation check. |
| J03 | Sum over Y for X marginal | Core | C125:95-105. Same progression and orientation check. |
| J04 | Sum over X for Y marginal | Core | C125:95-105. Same progression and orientation check. |
| J05 | Joint event and boundaries | Core | C125:95-105. Same progression and orientation check. |
| J06 | Event involving a sum | Core | C125:95-105. Same progression and orientation check. |
| J07 | Missing probability | Core | C125:95-105. Same progression and orientation check. |
| J08 | Normalisation allowing zero mass | Core | C125:95-105. Same progression and orientation check. |
| J09 | Coefficient normalisation | Core | C125:95-105. Same progression and orientation check. |
| J10 | Interior cells versus marginals | Core | C125:95-105. Same progression and orientation check. |
| C01 | Conditional Binomial | Core | C125:72-78,110-117. Retain and explain parameters/support. |
| C02 | Binomial complement | Core | C125:72-78,110-117. Retain and explain parameters/support. |
| C03 | Conditional Poisson and interval parameter | Core | C125:92-93,110-117. Retain and explain parameters/support. |
| C04 | Conditional Poisson CDF | Core | C125:92-93,110-117. Retain and explain parameters/support. |
| C05 | Shift failures to attempts | Core | C125:79-81,110-117. Retain and explain parameters/support. |
| C06 | Geometric conditional tail | Core | C125:79-81,110-117. Retain and explain parameters/support. |
| C07 | Conditional Exponential intuition | Preview | C210:170-176. Supply definitions/formulas before optional practice. |
| C08 | Substitute in an Exponential CDF | Preview | C210:170-176. Supply definitions/formulas before optional practice. |
| C09 | Conditional Normal mean/variance | Preview | C210:183-188. Explain concepts and ask about parameter/probability changes rather than copying a supplied name. |
| C10 | Normal standardisation/tail | Further | C210:183-188. Optional later methods. |
| C11 | Continuous Uniform range/density | Preview | C210:169. Explain concepts and ask about parameter/probability changes rather than copying a supplied name. |
| C12 | Uniform interval probability | Preview | C210:169. Supply definitions/formulas. |
| C13 | Gamma shape/rate | Further | C210:177-181. Optional later methods. |
| E01 | Binomial mean | Core | C125:58-59,72-78. Emphasise parameters and units. |
| E02 | Poisson interval mean | Core | C125:58-59,92-93. Emphasise parameters and units. |
| E03 | Exponential mean | Preview | C125:58-59, C210:170-176. Provide definitions. |
| E04 | Uniform second moment | Further | C125:60-61, C210:169. Use a discrete example for the core expectation objective. |
| E05 | Variance definition in a Normal setting | Preview | C125:63-68, C210:183-188. Variance is core, so prioritise a simple discrete version. |
| E06 | Exponential second moment | Further | C125:60-68, C210:170-176. Use a discrete example for the core objective. |
| E07 | Conditional Binomial mean | Core | C125:72-78,136-137. Emphasise parameters/units. |
| E08 | Conditional Poisson means under two weather conditions | Core | C125:92-93,136-138,146. Add weighting by weather probabilities. |
| E09 | Conditional Normal mean function | Preview | C125:136-147, C210:183-188. Could become core with a supplied conditional-mean function or a discrete setting. |

## Priority teaching improvements

| ID | Finding | Recommendation and acceptance | Status at that stage |
|---|---|---|---|
| T125-01 | Continuous/core questions mixed in one Next route | Default core, explicit optional routes and independent counts, retain IDs | Implemented 30/8/4 with transient-navigation fix |
| T125-02 | Limited CDF/independence/table-to-mean practice | B01–B08 use table reading and multiple numerical fields | O01, J11–13, C14–15, E10–11 implemented, with hints/solutions supporting written explanations |
| T125-03 | Name-only questions omit Tutorial 7 parameter/assumption tasks | Add support/parameters and discrete Hypergeometric/Negative Binomial examples | C16–17 check name/parameters/means, with assumptions/support explained. Older name rules retained. |
| T125-04 | Core expectation/variance taught through continuous settings | Use DU(5) second moment, squared mean and variance | E11 implemented, E10 covers discrete E[XY], means and total expectation |
| T125-05 | Formula-first pages lack prerequisites | Variable/value, direction, units glossary and running discrete example | Home prerequisites/glossary, chapter cues and 20-observation example implemented |
| T125-06 | Story/3D/complex formulas compete with initial learning | Game after discrete foundations, table/2D first, 3D optional | Concept-first changes on 1 November, with game story order retained |
| T125-07 | Shepherd direction conflicts with 100+20w, approximation signs, Uniform wording and Gamma positivity | Clarify assumptions/units/intervals while retaining original answers | Wording fixed and verified |
| T125-08 | Unexplained default 188/221 fractions | Give a valid cards interpretation and simpler frequency example | Cards/frequency/zero-marginal examples and custom-variable cues implemented |
| T125-09 | Question parameters exceed controls | Reproduce question models/events in plots | Fifteen presets, λ≤30, μ±100 and Uniform b≤200, with x synchronisation and fixed question answers |

The course also includes covariance/correlation and Markov chains in Chapters 9–11. The review focused on strengthening existing topics.

## Recommended learning sequence

1. Prerequisites in Chapters 2–4, translating words into events, conditional probability and independence.
2. Chapter 5 discrete foundations, PMF validity, CDF jumps/inequalities, expectation and variance.
3. Chapter 6 named models, variables, support, assumptions, parameters and events, followed by the game.
4. Chapter 7 joint/marginal tables, headers, event cells and independence.
5. Chapter 7 conditional PMFs, fixing a condition, renormalising and comparing directions.
6. Chapter 8 conditional/total expectation, deriving the conditional PMF, then its mean, then weighting by condition probabilities.
7. Optional Uniform area, Exponential waiting time and Normal location/scale intuition, with the needed definitions.

Later core topics identify what students need to have studied first.

## Original core-exercise proposals

These fictional observations use two binary indicators X/Y and 20 observations.

| X\Y | 0 | 1 | Total |
|---|---:|---:|---:|
| 0 | 6 | 4 | 10 |
| 1 | 2 | 8 | 10 |
| Total | 8 | 12 | 20 |

| ID | Task/objective | Exact results and feedback |
|---|---|---|
| B01 | Convert frequencies to a valid joint PMF | Row order 3/10,1/5,1/10,2/5, all nonnegative, sum 1 |
| B02 | For Bernoulli(.4), compare F(0), P(X<1), P(X≥1), P(X>1) | 3/5,3/5,2/5,0. For integer X, P(X≥k)=1−F(k−1). |
| B03 | Find P(X=1), P(Y=1) | 1/2,3/5, summing over the other variable |
| B04 | Compare P(X=1,Y=1), P(Y=1\|X=1), P(X=1\|Y=1) | 2/5,4/5,2/3, identifying cells and the conditioning denominator |
| B05 | Assess independence | Dependent, since 2/5 differs from (1/2)(3/5)=3/10. One counterexample refutes independence, while proof requires all supported cells. |
| B06 | Conditional means, overall mean, total expectation and E[XY] | 2/5,4/5,3/5, with (1/2)(2/5)+(1/2)(4/5)=3/5 and E[XY]=2/5. Distinguish a fixed-x value from E[Y\|X]. |
| B07 | For Z~DU(5), calculate E[Z²], E[Z]², Var(Z) | 11,9,2, using discrete sums |
| B08 | Replace rows by (0,0) and (1/4,3/4), condition on X=0 | Undefined because P(X=0)=0. Contrast P(Y=1\|X=1)=3/4. |

A supplementary model proposal samples without replacement from 20 tokens, eight red, with fixed count X=x and Y red tokens, giving `Y|X=x ~ Hypergeometric(n=x,M=8,N=20)`. State x's range and sampling assumptions.

A valid possible interpretation of the default table is two draws without replacement from 52 cards with four Aces. Binary X/Y indicate Aces in each draw. Cells are `48×47/(52×51)=188/221`, `48×4/(52×51)=16/221`, `4×48/(52×51)=16/221`, `4×3/(52×51)=1/221`. This interpretation was independently derived in the review.

## Minimum glossary

- **X and x.** X is a random variable, x a specified/observed value.
- **PMF and PDF.** Discrete height is point probability, continuous interval area is probability and continuous point probability is zero. Use equal-length interval explanations for continuous Uniform.
- **Direction.** Y|X=x fixes X and varies Y. X|Y=y fixes Y and varies X.
- **Geometric.** The course counts failures before success, starting at 0. Attempts including success add 1.
- **Units.** Poisson's interval mean is rate × interval length. Exponential rate has inverse-time units.
- **Conditional expectation.** E[Y|X=x] is a number for a fixed x. E[Y|X] varies with X, and total expectation averages it with the marginal weights.
- **Independence.** Equal conditional means or zero covariance alone generally do not establish independence. Check distributions/joint probabilities.

## Optional-preview limits

Two or three short tasks were proposed, including Uniform(0,10) point probability 0 and interval [2,5] probability 3/10, a supplied Exponential mean formula connecting higher rate to shorter waiting, and changes to Normal location/scale. Explain variance versus standard deviation before standardisation. More advanced integration, special functions and tail lookup remain voluntary later exploration.

## Initial verification and subsequent work

All original 32 answer/fraction/name/pair/tolerance fields matched `eabd184`. B01–B08 and the possible cards setting were independently checked using rational arithmetic, and all eight PDF hashes were checked. Wording changes passed [300/300 actual-module checks](evidence/teaching_regression_2026_10_31.json) and R parsing. That initial review retained layout/calculation/route implementations and its existing browser coverage.

Subsequent work is in [content verification](evidence/content_verification.md) and [layout verification](evidence/layout_verification.md). Teachers/users were to experience the core route and review difficulty, hints and optional content. The game retained story order.

## Historical implemented exercises and operations

| New question | Content | Results |
|---|---|---|
| O01 | Bernoulli(.4) CDF and strict/inclusive events | .6,.6,.4,0 |
| J11 | Convert the 20-observation 2×2 table | .3,.2,.1,.4 |
| J12 | Marginals | P(X=1)=.5, P(Y=1)=.6 |
| J13 | Independence counterexample | Joint .4 differs from product .3 |
| C14 | Joint, conditional and reverse conditional | .4,.8,2/3 |
| C15 | Zero conditioning probability and positive contrast | Undefined at X=0, P(Y=1\|X=1)=3/4 |
| C16 | Without-replacement model, parameters and mean | Hypergeometric(n=5,M=8,N=20), mean 2 |
| C17 | Failures before the second success | Negative Binomial(k=2,p=1/4), mean 6 |
| E10 | Conditional/overall means, total expectation and E[XY] | .4,.8,.6,.6,.4 |
| E11 | DU(5) second moment, squared mean and variance | 11,9,2 |

At that stage sidebar paths filtered Next/Back within each collection. Core counts were Overview 1, Joint 13, Conditional 10 and Expectation 6. All fields had to be correct and repeat success counted once per session. Refresh/new sessions reset progress. The game retained its separate 21-point rule.

Questions' models/events/reference tables remained fixed, while loading copied their parameters into interactive controls. Changing plots did not change question answers. Preview offered Uniform/Exponential/Normal and three observation tasks with formulas collapsed. Gamma/Beta/χ²/t/F remained further exploration.

The subsequent concept-first layout entered review from Home, followed by exploration and optional questions. Concepts appeared initially, full formulas expanded, tables/plots responded to width and 3D/practice/progress were initially collapsed at that stage. Visible formulas were re-typeset after tab/expansion changes to prevent zero-width overlap.
