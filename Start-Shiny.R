# Run from the VS Code terminal: Rscript Start-Shiny.R
args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", args, value = TRUE)
project_dir <- if (length(script_arg)) {
  dirname(normalizePath(sub("^--file=", "", script_arg[[1]]), mustWork = TRUE))
} else {
  normalizePath(getwd(), mustWork = TRUE)
}

if (.Platform$OS.type == "windows") {
  Sys.setlocale("LC_CTYPE", ".UTF-8")
}
options(encoding = "UTF-8")

local_library <- file.path(project_dir, ".R-library")
dir.create(local_library, showWarnings = FALSE, recursive = TRUE)
.libPaths(c(local_library, .libPaths()))
packages <- c("shiny", "bs4Dash", "shinyjs", "plotly", "ggplot2", "latex2exp", "dplyr")
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  install.packages(missing, lib = local_library, repos = "https://cloud.r-project.org")
}
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Missing R packages: ", paste(missing, collapse = ", "))
}

setwd(file.path(project_dir, "Project_PPeek1ng"))
shiny::runApp(
  appDir = getwd(),
  host = "127.0.0.1",
  port = 7125,
  launch.browser = !("--no-browser" %in% commandArgs(trailingOnly = TRUE))
)
