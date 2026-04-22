README.txt
==============

Code used to reproduce the scRNA-seq (Seurat) analyses and figures for the publication:
"TNF-α induces type I IFN signalling to suppress neurogenesis and recruit T cells."

This repository contains analysis code, metadata, and a reproducible R environment. Processed input data are not included due to file size constraints.


1) Folder contents
------------------

Folders:
  - data/            Documentation describing required input data structure (see data/README_data.txt)
  - scripts/         Analysis code (R scripts and R Markdown notebooks)
  - results/         Output intermediate objects (e.g., .rds)
  - figures/         Output figures (PDF)
  - renv/            Reproducible R package environment (used with renv.lock)

Files:
  - NCOMMS-25-62738-T_CodeForReview.Rproj   RStudio project file (recommended entry point)
  - renv.lock                               Locked package versions for reproducibility
  - libraries.tsv                           Library IDs and expected paths to 10x filtered matrices
  - hashtags.tsv                            Hashtag (HTO) feature to biological condition mapping
  - README.txt                              This file

2) Overview of analysis scripts
-------------------------------

The analysis is organized into three R Markdown notebooks, supported by a shared setup script:

  scripts/00_setup.R
    - Loads required packages (does not auto-install)
    - Defines project paths (data/, results/, figures/)
    - Reads and validates metadata files: libraries.tsv and hashtags.tsv

  scripts/01_load_and_qc.Rmd
    - Loads each 10x library from data
    - Performs quality control and filtering
    - Saves intermediate objects to results

  scripts/02_normalisation_and_clustering.Rmd
    - Normalization (SCTransform) and dimensionality reduction
    - Clustering / UMAP embedding
    - Saves intermediate objects and outputs to results

  scripts/03_analysis.Rmd
    - Downstream analyses (e.g., marker genes, functional enrichment, TF activity scoring)
    - Generates and saves figures to figures/ and results to results/


3) Requirements
---------------

3.1 System requirements (OS + software dependencies)
----------------------------------------------------
Operating system(s) tested:
  - macOS 14.3.1 (23D60)

R version:
  - R version 4.4.1

R package dependencies:
  - All R package versions are pinned in renv.lock and can be installed using:
        install.packages("renv")
        renv::restore()
  - Core packages include (full list is checked/loaded in scripts/00_setup.R):
        Seurat, SeuratObject, Matrix, dplyr, readr, ggplot2, scCustomize, scales,
        tidyr, tibble, pheatmap, clusterProfiler, org.Hs.eg.db, biomaRt,
        decoupleR, OmnipathR

Additional requirements:
  - Internet access may be required for steps that query external resources (e.g., OmniPath/CollecTRI),
    depending on the analyses run in scripts/03_analysis.Rmd. Downloaded resources are cached after first use.
  - No non-standard hardware is required for the demo/full run; however, for the full dataset a machine with ≥32 GB RAM is recommended

3.2 General notes
-----------------
- R (recommended: run via RStudio using the provided .Rproj file)
- Packages are managed via renv (recommended for reproducibility).


4) How to run the full pipeline (recommended)
---------------------------------------------

Step 1: Open the project
  - Open: NCOMMS-25-62738-T_CodeForReview.Rproj

Step 2: Restore the R package environment (renv)
  In the R console (from the project root):

    install.packages("renv")      # only needed if renv is not already installed
    renv::activate()
    renv::restore(prompt = FALSE) # installs the package versions listed in renv.lock
    If renv::restore() prompts that the project has not been activated, choose 1: Activate the project and use the project library.

    Typical installation time: ~10–30 minutes on a standard desktop/laptop, depending on internet speed and whether packages are installed from source or binaries.

Step 3: Obtain processed input data

- Processed 10x Genomics filtered_feature_bc_matrix directories are required but are not included in this repository
- See: data/README_data.txt
- Place downloaded matrices in the expected directory structure under data/

Step 4: Run the complete pipeline
  In the R console:

    source("scripts/99_run_all.R")

    Expected runtime: ~1–4 hours on a standard desktop (≥32 GB RAM)

This will:
  - source scripts/00_setup.R
  - render scripts/01_load_and_qc.Rmd
  - render scripts/02_normalisation_and_clustering.Rmd
  - render scripts/03_analysis.Rmd
  - write a run log to: results/run_log.txt


5) Running step-by-step (alternative)
-------------------------------------

If you prefer to run notebooks individually:

    install.packages("renv")
    renv::restore()

    source("scripts/00_setup.R")

    rmarkdown::render("scripts/01_load_and_qc.Rmd")
    rmarkdown::render("scripts/02_normalisation_and_clustering.Rmd")
    rmarkdown::render("scripts/03_analysis.Rmd")


6) Inputs and metadata files
----------------------------

Input data:
- Not included in this repository due to file size constraints
- The analysis requires four 10x Genomics Cell Ranger "filtered_feature_bc_matrix/" directories
- See: data/README_data.txt

Metadata:
  - libraries.tsv
      Required columns:
        - library_id
        - matrix_dir
      matrix_dir points to the corresponding filtered_feature_bc_matrix directory for each library.

  - hashtags.tsv
      Required columns:
        - library_id
        - hto_feature
        - bio_sample_id

These files are read and validated in scripts/00_setup.R.


7) Outputs
----------

- Figures:
    figures/
  (e.g., PDF figures saved using ggsave() and other plotting functions)

- Results / intermediate objects:
    results/
  (e.g., saved Seurat objects or analysis tables, typically as .rds or .csv)

- Run log:
    results/run_log.txt


8) Troubleshooting
------------------

- Package installation issues:
    Ensure you ran renv::restore() from the project root (same directory as renv.lock).

- File/path issues:
    Open the .Rproj file and confirm the working directory is the project root:
      getwd()

- Missing data directories:
    scripts/00_setup.R checks that all matrix_dir values in libraries.tsv exist.
    If directories are missing, download processed matrices and place them under data/ as described in data/README_data.txt.


9) Contact
----------

For questions about the data organization or code execution, please contact:
  sandrine.1.thuret@kcl.ac.uk

