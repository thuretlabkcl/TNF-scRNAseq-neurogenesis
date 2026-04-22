README_data.txt
==============

This folder describes the input data required to run the scRNA-seq analysis code provided for publication: "TNF-α induces type I IFN signalling to suppress neurogenesis and recruit T cells." 

1) Contents of this folder
--------------------------
Due to file size constraints, the processed single-cell RNA-seq data (10x Genomics feature-barcode matrices) are not included directly in this repository.

The analysis pipeline expects input data in the form of four 10x Genomics Cell Ranger "filtered_feature_bc_matrix" directories, each containing:

filtered_feature_bc_matrix/
- barcodes.tsv.gz
- features.tsv.gz
- matrix.mtx.gz

Expected directory structure (relative to the project root):

data/Lib1_Prolif_48h/filtered_feature_bc_matrix/
data/Lib2_Diff_Ctrl/filtered_feature_bc_matrix/
data/Lib3_Diff_TNF0.1/filtered_feature_bc_matrix/
data/Lib4_Diff_TNF1/filtered_feature_bc_matrix/

These matrices are used as input to Seurat via Read10X() / CreateSeuratObject() in scripts/01_load_and_qc.Rmd.

(Recommended: open the .Rproj file and run from the project root.)

2) Mapping to biological conditions (hashtag multiplexing)
----------------------------------------------------------
Each 10x library was multiplexed using TotalSeqB hashtag oligonucleotides (HTOs).

The mapping of HTO feature names to biological conditions/timepoints is provided in:

hashtags.tsv (project root)
../hashtags.tsv (relative to this data/ folder)

A summary of which conditions are present in each library is provided in:

libraries.tsv (project root)
../libraries.tsv (relative to this data/ folder)

(HTO feature names in hashtags.tsv correspond to entries in features.tsv.gz.)

3) Relationship to raw sequencing data (SRA)
--------------------------------------------
Raw FASTQ files have been deposited in the Sequence Read Archive (SRA) under:

BioProject accession: PRJNA1397568

4) Access to processed data
-------------------------

Processed single-cell RNA-seq data (filtered feature-barcode matrices) were generated from the raw sequencing data using 10x Genomics Cell Ranger v7.1.

These processed matrices are required to run the analysis pipeline and are not included in this repository due to file size constraints.

They will be made available via a public repository (e.g., GEO or Zenodo).

After downloading, place the matrices in the directory structure described in Section 1.

5) Contact
----------
For questions about the data organization, please contact: sandrine.1.thuret@kcl.ac.uk