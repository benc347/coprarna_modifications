# CopraRNA Modifications

**PLEASE CITE THE ORIGINAL PUBLICATIONS**

Comparative genomics boosts target prediction for bacterial small RNAs Patrick R. Wright, Andreas S. Richter, Kai Papenfort, Martin Mann, Jörg Vogel, Wolfgang R. Hess, Rolf Backofenb, and Jens Georg Proceedings of the National Academy of Sciences of the USA, 110, E3487-E3496, 2013, DOI(10.1073/pnas.1303248110).

CopraRNA and IntaRNA: predicting small RNA targets, networks and interaction domains Patrick R. Wright, Jens Georg, Martin Mann, Dragos A. Sorescu, Andreas S. Richter, Steffen Lott, Robert Kleinkauf, Wolfgang R. Hess, and Rolf Backofen Nucleic Acids Research, 42, W119-W123, 2014, DOI(10.1093/nar/gku359).

**Introduction**

This repository contains modified source code of CopraRNA2 v2.1.3 (Patrick R Wright et al. - https://github.com/PatrickRWright/CopraRNA).

CopraRNA is a powerful program that leverages RNA-RNA interaction prediction and comparative genomics to predict putative targets of bacterial small RNAs. In its original implementation, only genomes in the NCBI RefSeq database can be analyzed by CopraRNA. Additionally, the user is not able to pass all possible arguments from CopraRNA to the underlying IntaRNA RNA-RNA interaction modeling program.

This modified code expands CopraRNA functionality to include *closed*, non-RefSeq genomes found available in the NCBI Genomes FTP site (https://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/prokaryotes.txt). Additionally, it allows the user to pass any IntaRNA option from CopraRNA, allowing additional control over RNA interaction parameters.

**Installation**

The simplest way to incorporate the modified code is the following:
  1. Create a fresh conda environment and install CopraRNA into it
  2. Copy the "copra_modifications_12_20" directory to the conda environment
  3. From the "copra_modifications_12_20" directory, run "prepare_mod_copra.sh"
  4. Run CopraRNA on non-RefSeq genomes and with additional parameters passed as a text file to the --intarna_file argument

Two additional scripts, "submit_multiple_copra.sh" and "run_copra.sh" are provided for running the modified CopraRNA code on a server. Also provided is "intaparams.txt", an example file of additional IntaRNA parameters.

