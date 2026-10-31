# Shiny Visualization Project

This repository contains the Shiny-based interactive visualization system developed for the dissertation project in Probability and Statistics Education.  
This tool enables learners to explore probability distributions through interactive graphics, hands-on experimentation, and storytelling elements that bring abstract ideas to life.

The current teaching revision defaults to **STATS125 Core**, with separate **Optional STATS210 preview** and **Further exploration** paths. It retains the original 32 exercises and adds 10 core exercises: 30 core, 8 preview and 4 further exercises in total. Practice progress is separate for each path and lasts for the current session; the discrete game keeps its own score. Worked-example buttons load the parameters used in a question into its tables or plots. See the [teaching review](review/TEACHING_REVIEW_STATS125.md) and [verification record](review/evidence/content_verification.md).

Home now links directly to practice, and each module provides section shortcuts. Practice and the interactive table share the main workspace, stacking on smaller windows; theory expands across the available width and 3D plots are optional. See the [layout verification](review/evidence/layout_verification.md) for the tested widths and display fixes.

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
