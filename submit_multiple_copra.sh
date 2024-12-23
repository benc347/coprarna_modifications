#!/bin/bash 

#example SLURM script for running the modified CopraRNA2 pipeline

#####INPUT YOUR JOB SUMISSION INFO HERE#########

#accept user input
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
runcode=$1
upstreamdist=$2
downstreamdist=$3
regiontype=$4

#if runcode is left empty, then give it a random string
runcode="${runcode:-$(openssl rand -hex 4)}"

#this script submits multiple copraRNA jobs
#keeps things separated so that crashes don't affect the entire run
#does the preparation for the inputs
envpath="/path/to/your/conda/environment"

#need to activate conda environment for final_build_kegg2refseq.pl
#conda install coprarna bioconda::perl-lwp-protocol-https
module load miniconda
source activate ${envpath}

#pull prokaryotes.txt from ncbi and convert to unix
#can take forever if run through sbatch (at least on my HPC), so probably just worth it to pull it manually every now and then
	#wget ftp://ftp.ncbi.nih.gov/genomes/GENOME_REPORTS/prokaryotes.txt
	#dos2unix prokaryotes.txt
	cp ${envpath}/copra_modifications_12_20/prokaryotes.txt ./

#build updated genomes list from user input
#this bypasses the limitation of CopraRNA to using only RefSeq genomes
${envpath}/bin/coprarna_aux/final_build_kegg2refseq.pl

#move the resulting output files to the coprarna_aux directory
mkdir ${envpath}/bin/coprarna_aux/${runcode}/
mv CopraRNA_available_organisms.txt ${envpath}/bin/coprarna_aux/${runcode}/
mv kegg2refseqnew.csv ${envpath}/bin/coprarna_aux/${runcode}/

#ensure that the .fa input file has things as RNA (T > U)
sed -i '/^>/!s/T/U/g' fastas/*.fa

#create subdirectories for each sRNA of interest
#run copraRNA2 for each sRNA

for file in fastas/*.f*a; do
	
	#create subdirectories for each sRNA of interest and copy run_copra.sh and .fa file into them
	filename="${file%.f*a}"
	mkdir ${filename##*/}
	cp run_copra.sh $file intaparams.txt ${filename##*/}/
	cd ${filename##*/}/
	
	#run the copraRNA2 script with the .fa file as the input
	sbatch run_copra.sh ${file#fastas/} $runcode $upstreamdist $downstreamdist $regiontype intaparams.txt
	cd ../
done

