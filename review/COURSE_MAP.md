# Course sources and module mapping, centred on STATS125

First checked on 2026-10-21. Teaching scope reviewed on 2026-10-31. All page references below are **one-based PDF pages**. The printed body-page numbers agree with the PDF pages in the listed coursebooks. This record contains source locations and review findings.

**The intended users are current STATS125 students who will study STATS210 later.** The app concentrates on discrete probability, joint and conditional distributions, and expectation. A small optional preview introduces ideas needed later in STATS210. Continuous distributions and integration for moments cannot be assumed prerequisites. See the [question-by-question teaching review](TEACHING_REVIEW_STATS125.md).

| Source ID | Local course source | Version and use |
|---|---|---|
| C125 | `Stat 125 Coursebook 2026 gapped_working file .pdf` under `G:\STATS\STATS125\2026_S2` | 2026 gapped coursebook, 205 pages. Main reference for definitions and discrete modules. |
| C210 | `Stat 210 gapped Coursebook 2024.pdf` under `G:\STATS\STATS210\2026_S2` | 2024 gapped coursebook in the downloaded course directory, 235 pages. Reference for continuous distributions and transformed expectations. Its version does not establish the complete 2026 teaching arrangements. |

Source identifiers, filenames and SHA-256 fingerprints are in [course_sources.json](evidence/course_sources.json). The directory contains historical copies, so total file counts were not treated as counts of independent course resources.

| App topic | STATS125 reference | STATS210 reference | Review use |
|---|---|---|---|
| PMF / CDF and valid probabilities | §5.2 p52, §5.3 p54 | §1.2 p6, Chapter 5 from p89 | Nonnegative probabilities and total mass 1. Distinguish probability from density. |
| Discrete models and game scenarios | Chapter 6 p69, Geometric p79–80, Negative Binomial p82, Discrete Uniform p91, Poisson p92–93 | Chapter 2 from p11, distribution summary p15 | Define the variable, independence assumptions and parameters before choosing a model. Missing information alone does not establish equal probabilities. |
| Joint, marginal and event sums | Chapter 7 p95–96, worked example p101 | Discrete review p8, continuous joint distributions in Chapter 6 | Joint-table total, marginal sums and cells belonging to an event. |
| Conditional PMF | §7.3, definition p114 | Discrete review p8, continuous conditional distributions in Chapter 6 | Divide each cell by the conditioning-event probability, which must be positive. |
| Discrete expectation and transformations | §5.4 p58, §5.5 p60, joint expectation p96 | §1.2 p6–7 | Weight numerical outcomes. A transformed expectation generally differs from the transformation of the expectation. |
| Continuous PDF / CDF / expectation | The STATS125 coursebook concentrates on discrete models | Chapter 5, p102 and p105–108 | Density differs from point probability. Continuous expectations use integration. |
| Uniform / Exponential / Gamma | C125 is not the main source for continuous models | Uniform p169, Exponential p170–175, Gamma p178–180 | `E[X²]=∫x²f(x)dx`. Exponential uses rate, Gamma uses shape/rate. |
| Conditional and total expectation | §8.3 from p136, total expectation p138/p146, §8.5 from p145 | §6.9 p153–154 | Later STATS125 core material. First fix x and calculate the mean, then weight over X. Distinguish a value from a random variable. |

C125 p79 and p114 and C210 p106 were rendered and visually checked. Other referenced pages were checked through text and formula inspection. Some solution steps in the gapped books are blank. Independent numerical calculations are recorded as independent checks.

C125 p79 explicitly defines Geometric as the number of failures before the first success, starting at 0, and notes the alternative convention counting total attempts. Overview follows that definition. Conditional Q5–Q6 explicitly use shifted variables following the earlier fix. Continuous joint distributions and other STATS210 material are only partly covered and were outside the new-module scope of this round.

## Learning-path conclusions on 2026-10-31

| Level | Content at that stage | Treatment |
|---|---|---|
| STATS125 core | Seven discrete distributions, PMF/CDF, E[g(X)], variance, joint and marginal distributions, independence, conditional distributions, discrete conditional and total expectation | Default route. Later core topics identify their prerequisite chapters and remain in STATS125. |
| Optional preview | Density/area for continuous Uniform, Exponential and Normal, waiting times, location and scale | Voluntary exploration after the core route, with the required definitions and formulas. |
| Further exploration | Gamma/Beta/χ²/t/F, integration for moments and Normal tail probabilities | Optional, initially collapsed content. The classification describes this app's learning route. |

The original 32 questions were classified as follows. All 10 Joint questions were core. Conditional Q1–6 were core, Q7/8/9/11/12 preview, and Q10/13 further exploration. Expectation Q1/2/7/8 were core, Q3/5/9 preview, and Q4/6 further exploration. Totals were **20 core, 8 preview and 4 further**. Variance in E5 is a core concept, but its Normal setting placed that version in preview. A discrete replacement could serve the core route.

The review also checked 2026 S2 Tutorials 4/6/7/8, test information and the formula sheet. Identifiers, versions, page counts and SHA-256 values for the eight selected PDFs are in the [teaching evidence index](evidence/teaching_scope_2026_10_31.json). Tutorial 7 asks for conditional PMFs, model parameters and assumptions. Tutorial 8 uses total expectation. The mid-semester test's Chapters 2–6 scope applies to that test.

The app supports selected topics in Chapters 5–8. Adding Markov chains or implementing a complete STATS210 course was outside this review's scope.

Subsequent historical content work implemented those classifications and added 10 core questions, giving 30 core questions (Overview 1 / Joint 13 / Conditional 10 / Expectation 6), 8 preview and 4 further-exploration questions with separate counts. Core topics included discrete second moments, variance, conditional and total expectation. Preview offered Uniform / Exponential / Normal, with the other continuous distributions in further exploration. Fifteen plotting presets linked questions to their parameters. See the [content record](evidence/content_verification.md) and [42-question catalogue and plot parameters](evidence/content_learning_paths.json). The later exam-only revision superseded that student question catalogue.
