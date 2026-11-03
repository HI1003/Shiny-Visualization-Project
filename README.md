# Shiny Visualization Project

This repository contains the Shiny-based interactive visualization system developed for the dissertation project in Probability and Statistics Education.  
This tool enables learners to explore probability distributions through interactive graphics, hands-on experimentation, and storytelling elements that bring abstract ideas to life.

The current teaching revision defaults to **STATS125 Core**, with separate **Optional STATS210 preview** and **Further exploration** paths. The learning order is **review key ideas → explore tables and plots → optional past-exam extracts**. Practice and progress are collapsed by default. The four module practice panels use only locally verified STATS125 past-exam extracts; the previous original and unverified exercise library is no longer offered in those panels. The separate detective game and generic visualization examples remain available.

The selected extracts are from 2026 S1 Q2(a)–(d), 2025 S1 Q3(c)–(d), 2024 S2 Q3(e), and 2026 S1 Q3(d), (g). Each identifies its source and adaptation status and can load the corresponding table or plot parameters. **Exam content and source PDFs are local-only:** a public clone still runs the visualizations but shows no exam questions until a private bank and its matching local PDFs are available. There is no fallback to original exercises. See [selection and local setup](review/PAST_EXAM_SELECTION.md) and [current verification](review/evidence/past_exam_verification.md). Older teaching/layout reports describe earlier revisions.

Probability tables now offer **Auto**, **Short decimals**, and **Simple fractions** through the sidebar. Ordinary decimals use at most four decimal places without trailing zeroes; very small nonzero values use scientific notation, and approximate entries are marked. Hover for more precision or expand **More precision** in Overview. Compact editor bindings preserve the original value until an entry is edited. See [number-display verification](review/evidence/number_display_verification.md).

## Project Overview

The Shiny application helps students learn key probability concepts through simulation and dynamic visualization.  
Users can interactively manipulate parameters, visualize how probability functions change, and explore statistical relationships in real time.

### Core Modules

| Module | Description |
|:--------|:-------------|
| **Main Application (`main.R`)** | Integrates all modules into a unified Shiny dashboard. |
| **Shiny entry point (`app.R`)** | Loads the dashboard through the application directory so bundled images are served correctly. |
| **Probability Distribution (`module_probability.R`)** | Visualizes major discrete and continuous distributions, including Bernoulli, Binomial, Poisson, and Normal. |
| **Game: Discrete (`module_game_discrete.r`)** | An interactive detective-style probability game that strengthens conceptual understanding through contextual tasks. |
| **Joint Distribution (`module_joint.R`)** | Enables users to construct and explore joint PMFs, marginal, and conditional distributions. |
| **Conditional Distribution (`module_conditional.R`)** | Demonstrates how conditional probabilities evolve based on different given conditions. |
| **Expectation (`module_expectation.R`)** | Allows learners to compute and visualize expectations of random variables using table-based PMFs. |

---

## Included Resources

The packaged file `Project_PPeek1ng.zip` includes:
- All R source files listed above  
- Image and visualization assets used across modules  
- A structured directory ready for deployment on RStudio or Shiny Server

---

## How to Run

1. Download or clone this repository:
   ```bash
   git clone https://github.com/D1OK1NG/Shiny-Visualization-Project.git
   ```
2. Unzip `Project_PPeek1ng.zip` if the `Project_PPeek1ng` folder is not already present.
3. Open the repository folder in VS Code. R and `Rscript` must be available on your PATH.
4. Open the integrated terminal and run:
   ```powershell
   Rscript Start-Shiny.R
   ```
   The launcher installs any missing dependencies into the project-local `.R-library`
   folder on the first run (internet access is required for installation).
   You can also use **Terminal > Run Task > Run Shiny app** in VS Code.
5. The dashboard opens at `http://127.0.0.1:7125`. Keep the terminal open;
   press **Ctrl+C** to stop the app. Only one instance can use this port at a time.

In RStudio, set the working directory to the repository root and run
`source("Start-Shiny.R")`.

Review status and reproducible checks are recorded in [review/README.md](review/README.md).
Run `./review/scripts/run_regression.ps1` from the repository root to check the modules;
with the app running, `./review/scripts/test_assets.ps1` checks its image resources.

---

## Academic Context

This project was developed as part of a Master’s dissertation focused on enhancing probability and statistics learning through interactive visualization.  
It combines statistical theory, pedagogical design, and data-driven user interaction using R and Shiny.

The project was completed under the academic supervision of **Dr. Azam Asanjarani** and **Dr. Heti Afimeimounga**, whose guidance and insights were invaluable in shaping the educational design and overall structure of this work.

For detailed methodology, educational design, and system architecture, please refer to the dissertation document.

---

## Repository Structure

```
Shiny-Visualization-Project/
│
├── Project_PPeek1ng.zip          # Full Shiny project archive
├── README.md                     # Project documentation
└── (unzipped folder contents)
    ├── main.R
    ├── module_probability.R
    ├── module_game_discrete.r
    ├── module_joint.R
    ├── module_conditional.R
    ├── module_expectation.R
    └── images/
```

---

## License & Citation

This project is shared under the MIT License for academic and educational purposes.  
If you reference or reuse this work, please cite:

> Wu, Chunyi (2025). *Shiny-Based Probability Visualization Project.* University of Auckland.  
> GitHub: [https://github.com/D1OK1NG/Shiny-Visualization-Project](https://github.com/D1OK1NG/Shiny-Visualization-Project)

---

## Contact

**Author:** Chunyi Wu  
**Institution:** University of Auckland — Master of Professional Studies in Data Science  
**Supervisors:** Dr. Azam Asanjarani, Dr. Heti Afimeimounga  
**Email:** cwu112@aucklanduni.ac.nz  
**GitHub:** [https://github.com/D1OK1NG](https://github.com/D1OK1NG)
