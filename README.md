# Shiny Visualization Project

This repository contains the Shiny-based interactive visualization system developed for the dissertation project in Probability and Statistics Education.  
This tool enables learners to explore probability distributions through interactive graphics, hands-on experimentation, and storytelling elements that bring abstract ideas to life.

**Probability Distribution → Overview** defaults to **STATS125 Core**. Its **Learning path** selector also offers **Optional STATS210 preview** and **Further exploration**. The learning order is **review key ideas → explore tables and plots → optional past-exam extracts**. Practice is collapsed by default, with progress shown within each module's optional questions. Modules are accessed through the sidebar. The four module practice panels use only locally verified STATS125 past-exam extracts; the previous original and unverified exercise library is no longer offered in those panels. The separate detective game and generic visualization examples remain available.

The selected extracts are from 2026 S1 Q2(a)–(d), 2025 S1 Q3(c)–(d), 2024 S2 Q3(e), and 2026 S1 Q3(d), (g). Each identifies its source and adaptation status and can load the corresponding table or plot parameters. **The four question groups and six matching source PDFs are included in `exam-materials/`.** Their paths are resolved relative to the bank file, so cloning or downloading the current repository provides the complete reviewed app. The launcher discovers the bundled materials automatically. See [source selection and loading](review/PAST_EXAM_SELECTION.md). Older teaching/layout reports describe earlier revisions, when exam materials were stored separately.

Probability tables automatically use short decimals and simple fractions. Joint tables and heatmaps prefer simple fractions. Conditional and Expectation charts follow their corresponding table formats. Ordinary decimals use at most four decimal places without trailing zeroes; very small nonzero values use scientific notation, and approximate entries are marked. Compact editor bindings preserve the original value until an entry is edited. See [number-display verification](review/evidence/number_display_verification.md).

Distribution parameters support synchronized sliders and numeric inputs, with range and integer checks. Overview plots use linked hover or touch readings. Continuous plots choose an x query step for the current axis scale and calculate both the PDF and CDF at that x. Joint uses a numerical heatmap and Conditional uses a bar chart. Expectation shows each conditional mean multiplied by its marginal probability, then adds the contributions to obtain the overall mean. Optional exam sections and their navigation appear when verified questions are available for the selected scope. Current delivery checks and limitations are recorded in the [handover](review/HANDOVER.md); individual changes are recorded in the [work log](review/WORKLOG.md).

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

The current application is in the versioned `Project_PPeek1ng/` directory, with its R modules and bundled images. `Start-Shiny.R` launches that directory. Review records and regression scripts are in `review/`.

`Project_PPeek1ng.zip` preserves the original project implementation with its comments translated into English. For the reviewed version, download the full current repository using **Code → Download ZIP**, or clone it using the instructions below.

---

## How to Run

1. Download or clone this repository:
   ```bash
   git clone https://github.com/HI1003/Shiny-Visualization-Project.git
   ```
2. For a GitHub ZIP download, extract the downloaded repository ZIP. The extracted repository includes the current `Project_PPeek1ng` folder and `Start-Shiny.R`.
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
the past-exam checks use the bundled bank and matching source PDFs.
With the app running, `./review/scripts/test_assets.ps1` checks its image resources.

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
├── Start-Shiny.R                 # Launcher and dependency setup
├── Project_PPeek1ng/             # Current application
│   ├── app.R
│   ├── main.R
│   ├── modules/
│   └── www/                      # Images, styles and browser interaction
├── review/                      # Review records and validation scripts
├── exam-materials/              # Four question groups and six matching PDFs
├── README.md
└── Project_PPeek1ng.zip          # Original implementation, English comments
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
