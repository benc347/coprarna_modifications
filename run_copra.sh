#!/bin/bash 

###YOUR JOB SUBMISSION INFO HERE###

#take input from batch file or provide it directly

#fasta - multifasta file of homologs for a single sRNA
#	fasta headers should be the GenBank/RefSeq ID for an organism in a closed genome found in https://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/prokaryotes.txt
#runcode - alphanumeric
#	as part of working around the RefSeq database limitation in the original code
#		final_build_kegg2refseq.pl builds an updated genome list based on user input
#		the output is then moved to a directory in bin/coprarna_aux named $runcode
#upstreamdist and downstreamdist - integers
#	passed to the CopraRNA arguments --ntup and --ntdown, respectively
#	number of nucleotides upstream and downstream of the target region analyzed by CopraRNA
#regiontype - "5utr", "3utr", or "cds"
#	passed to the CopraRNA --region argument
#	determines region of annotated feature that will be assessed for sRNA interaction
#intaparams - a text file of IntaRNA parameters
#	file should contain a single line with all IntaRNA parameters of interest
#	see https://github.com/BackofenLab/IntaRNA for the exhaustive list of possible parameters
#	example format found in this repository: example_intaRNA_params.txt
fasta=$1
runcode=$2
upstreamdist=$3
downstreamdist=$4
regiontype=$5
intaparams=$6

#working in a conda environment, so activate it first
module load miniconda
source activate /path/to/your/environment/

#call modified copraRNA command
#NOTE: in many cases, the --enrich flag will not work for poorly studied organisms
#	this is because DAVID-WS only works for well-studied genomes
final_coprarna3.pl -srnaseq $fasta -runname $runcode -ntup $upstreamdist -ntdown $downstreamdist -region $regiontype -topcount 200 -cores 40 --verbose --cons 2 --intarna_file $intaparams
