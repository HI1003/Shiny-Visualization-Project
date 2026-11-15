# First-round browser reproduction record

2026-10-21, Windows Chrome, local `http://127.0.0.1:7125/`, launched with `Start-Shiny.R --no-browser`. Checks occurred after 15:18 NZDT. The work window is in WORKLOG. App baseline `0f609de`. Actions used actual page inputs/clicks, visible DOM and visual inspection.

| Check | Action | Observation | Result |
|---|---|---|---|
| B01 Home/navigation | Open app and enter each module | Home, Overview, Game, Joint, Conditional and Expectation accessible | Entry smoke checks pass |
| B02 Default conditional table | Enter Conditional with default f(Y\|X=0) | .92157, .92157, total 1.84313 | R1-05 reproduced |
| B03 Wrong name | Enter Negative Binomial in Conditional Q1, wait, Submit | `alert alert-success` with Binomial solution | R1-03 reproduced |
| B04 Correct Poisson probability | Advance to Q4, enter .347229417554172, wait, Submit | Warning asks for sum from 0 to 10 under Poisson(12) | R1-01 Q4 reproduced |
| B05 Exact fraction | Advance to Expectation Q4, enter 10000/3, wait, Submit | Warning asks for the second moment | R1-02 reproduced |
| B06 Joint default and bank | Read Joint exercise Q1 table | Nine fractions independently sum to 17/24 | R1-04 table visible, other questions checked from source |
| B07 Negative probability | Set Joint rows to -1,1,1,1, wait, Generate | Negative cells accepted while total is declared 1. Cells retain inputs and marginals use normalised values. | R1-06 reproduced |
| B08 Overview | Open Bernoulli, select Geometric, switch Continuous | PMF/CDF and PDF/CDF rendered. Geometric counts failures. Continuous help still refers to P(X=x). | Entry passes, R1-07 convention checked, R1-10 help issue |
| B09 Game chapter 1 | Immediate Response, Poisson, Determine | Correct feedback, model explanation and NEXT | Positive path passes |
| B10 Game chapter 2 | NEXT, Discrete Uniform, Determine | Correct feedback. Explanation asserts equal probabilities from missing information and nonconstant success probability for repeated DU sampling. | R1-11 reproduced |
| B11 Conditional layout | Inspect default table at about 1521px width | Condition selector covers the right side of the joint table, visually checked in-session | R1-10 reproduced, screenshot file not retained |
| B12 Restore data | Joint, Uniform, confirm four .25000 entries, Generate | Valid uniform table restored | Post-test state restored |

Shiny input, submission and feedback updates are asynchronous. Results use the confirmed updated feedback. B03 initially showed a hint in an immediate snapshot, then confirmed success after resubmission. The transient snapshot was excluded from the final judgement.

Browser feedback was combined with mathematical checks. Normal Q10, Joint Q2–Q10, p=1 boundaries, paired answers and zero-total input were not all operated in the browser. Evidence levels are in ISSUES. Mobile, complete accessibility, multi-user concurrency and deployment acceptance were outside the first round.
