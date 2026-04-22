#!/usr/bin/env Rscript

# scripts/99_run_all.R
# Run the full analysis pipeline for the scRNA-seq analysis repository

# ---------- helpers ----------
msg <- function(...) cat(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "-", ..., "\n")

find_project_root <- function() {
  wd <- normalizePath(getwd())
  while (TRUE) {
    has_rproj <- length(list.files(wd, pattern = "\\.Rproj$", full.names = TRUE)) > 0
    has_renv  <- file.exists(file.path(wd, "renv.lock")) || file.exists(file.path(wd, "renv", "activate.R"))
    if (has_rproj || has_renv) return(wd)
    parent <- dirname(wd)
    if (parent == wd) stop("Could not find project root (no .Rproj/renv.lock found) from: ", getwd())
    wd <- parent
  }
}

# Capture console output to a log
project_root <- find_project_root()
results_dir <- file.path(project_root, "results")
dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)
log_file <- file.path(results_dir, "run_log.txt")
sink(log_file, split = TRUE)
on.exit(sink(), add = TRUE)

msg("Project root detected: ", project_root)
setwd(project_root)
msg("Working directory set to project root.")

# ---------- renv restore (recommended) ----------
if (requireNamespace("renv", quietly = TRUE)) {
  msg("renv detected. Restoring environment from renv.lock ...")
  renv::restore(prompt = FALSE)
} else {
  msg("WARNING: renv is not installed. Install it with install.packages('renv') for reproducibility.")
}

# ---------- source shared setup ----------
msg("Sourcing scripts/00_setup.R ...")
source(file.path("scripts", "00_setup.R"))

# ---------- render Rmds in order ----------
if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  stop("Package 'rmarkdown' is required to render .Rmd files. Install via install.packages('rmarkdown').")
}

rmds <- c(
  file.path("scripts", "01_load_and_qc.Rmd"),
  file.path("scripts", "02_normalisation_and_clustering.Rmd"),
  file.path("scripts", "03_analysis.Rmd")
)

msg("Rendering Rmds:")
for (f in rmds) msg(" - ", f)

for (f in rmds) {
  if (!file.exists(f)) stop("Missing file: ", f)
  msg("Rendering: ", f)
  rmarkdown::render(
    input = f,
    output_format = "html_document",
    clean = TRUE,
    envir = new.env(parent = globalenv()),
    knit_root_dir = project_root
  )
  msg("Done: ", f)
}

msg("Pipeline complete.")
msg("Log written to: ", log_file)