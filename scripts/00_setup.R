# scripts/00_setup.R
# Shared setup for all analysis .Rmd files (packages, paths, metadata)

# Increase memory limit for parallel processing (future)
options(future.globals.maxSize = 4000 * 1024^2)

# ---------------------------
# Reproducibility + options
# ---------------------------
set.seed(42)
options(stringsAsFactors = FALSE)

msg <- function(...) {
  cat(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "-", ..., "\n")
}

# ---------------------------
# Required packages
# (Do NOT auto-install here)
# ---------------------------
required_pkgs <- c(
  "Seurat", "SeuratObject", "Matrix",
  "dplyr", "readr", "ggplot2", 'scCustomize', 'scales', 'clusterProfiler', 'org.Hs.eg.db', 'tibble','decoupleR', 'OmnipathR','tidyr','pheatmap', 'biomaRt')

missing_pkgs <- required_pkgs[!vapply(required_pkgs, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]
if (length(missing_pkgs) > 0) {
  stop(
    "Missing required packages: ", paste(missing_pkgs, collapse = ", "), "\n\n",
    "Please install project dependencies using renv from the project root:\n",
    "  install.packages('renv')\n",
    "  renv::restore()\n"
  )
}

# Quiet package loading
suppressPackageStartupMessages({
  library(Seurat)
  library(SeuratObject)
  library(Matrix)
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(scCustomize)
  library(scales)
  library(clusterProfiler)
  library(org.Hs.eg.db)
  library(tibble)
  library(decoupleR)
  library(OmnipathR)
  library(tidyr)
  library(pheatmap)
  library(biomaRt)
})

# ---------------------------
# Project paths (project root)
# ---------------------------
PROJECT_ROOT <- normalizePath(getwd())

DATA_DIR    <- file.path(PROJECT_ROOT, "data")
SCRIPTS_DIR <- file.path(PROJECT_ROOT, "scripts")
RESULTS_DIR <- file.path(PROJECT_ROOT, "results")
FIGURES_DIR <- file.path(PROJECT_ROOT, "figures")

dir.create(RESULTS_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIGURES_DIR, showWarnings = FALSE, recursive = TRUE)

# ---------------------------
# Input metadata file paths
# ---------------------------
LIBRARIES_TSV <- file.path(PROJECT_ROOT, "libraries.tsv")
HASHTAGS_TSV <- file.path(PROJECT_ROOT, "hashtags.tsv")

if (!file.exists(LIBRARIES_TSV)) stop("Cannot find libraries.tsv in project root: ", PROJECT_ROOT)
if (!file.exists(HASHTAGS_TSV))  stop("Cannot find hashtags.tsv or hashtag.tsv in project root: ", PROJECT_ROOT)

msg("Project root: ", PROJECT_ROOT)
msg("Using: ", basename(LIBRARIES_TSV), " and ", basename(HASHTAGS_TSV))

# ---------------------------
# Read metadata
# ---------------------------
libraries <- readr::read_tsv(LIBRARIES_TSV, show_col_types = FALSE)
hashtags  <- readr::read_tsv(HASHTAGS_TSV,  show_col_types = FALSE)

# Remove empty rows (Excel spacer lines)
if ("library_id" %in% names(libraries)) {
  libraries <- libraries %>% filter(!is.na(.data$library_id) & .data$library_id != "")
}
if ("library_id" %in% names(hashtags)) {
  hashtags  <- hashtags  %>% filter(!is.na(.data$library_id) & .data$library_id != "")
}

# ---------------------------
# Validate required columns
# ---------------------------
req_lib_cols <- c("library_id", "matrix_dir")
req_hto_cols <- c("library_id", "hto_feature", "bio_sample_id")

missing_lib <- setdiff(req_lib_cols, names(libraries))
missing_hto <- setdiff(req_hto_cols, names(hashtags))

if (length(missing_lib) > 0) stop("libraries.tsv missing columns: ", paste(missing_lib, collapse = ", "))
if (length(missing_hto) > 0) stop("hashtag(s).tsv missing columns: ", paste(missing_hto, collapse = ", "))

# ---------------------------
# Validate matrix directories exist
# ---------------------------
bad_dirs <- libraries$matrix_dir[!dir.exists(libraries$matrix_dir)]
if (length(bad_dirs) > 0) {
  stop(
    paste0(
      "Required processed input data were not found.\n\n",
      "The following matrix_dir paths do not exist:\n",
      paste("  -", bad_dirs, collapse = "\n"),
      "\n\nProcessed 10x Genomics filtered_feature_bc_matrix directories are not bundled in this repository.\n",
      "Please see data/README_data.txt for the expected directory structure and instructions for obtaining the processed matrices."
    ),
    call. = FALSE
  )
}

# Validate hashtags reference known libraries
unknown_libs <- setdiff(unique(hashtags$library_id), unique(libraries$library_id))
if (length(unknown_libs) > 0) {
  stop("hashtag(s).tsv contains library_id not found in libraries.tsv: ",
       paste(unknown_libs, collapse = ", "))
}

# ---------------------------
# Helper functions
# ---------------------------

# Read 10x filtered feature-barcode matrix for a given library_id
read_10x_for_library <- function(lib_id) {
  row <- libraries %>% dplyr::filter(.data$library_id == lib_id)
  if (nrow(row) != 1) stop("Expected exactly one row in libraries.tsv for library_id = ", lib_id)
  msg("Reading 10x matrix for ", lib_id, " from: ", row$matrix_dir)
  Read10X(data.dir = row$matrix_dir)
}

# Save an R object to results/
save_rds <- function(x, filename) {
  out <- file.path(RESULTS_DIR, filename)
  saveRDS(x, out)
  msg("Saved RDS: ", out)
  invisible(out)
}

# Save a ggplot to figures/
save_plot <- function(p, filename, width = 7, height = 5) {
  out <- file.path(FIGURES_DIR, filename)
  ggsave(out, plot = p, width = width, height = height)
  msg("Saved plot: ", out)
  invisible(out)
}



