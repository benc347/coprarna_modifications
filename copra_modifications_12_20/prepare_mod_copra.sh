#!/bin/bash 

#SBATCH --time=48:00:00					##(day-hour:minute:second) sets the max time for the job
#SBATCH --cpus-per-task=1	 			##request number of cpus
#SBATCH --mem=4						##max ram for the job

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=bienvenido.tibbs-cortes@usda.gov		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="00_prepare_mod_copra_%j"		##names what slurm logfile will be saved to 

#create a new conda environment
	#please install coprarna into this environment using conda
	#add the directory coprarna_modifications to your conda environment
		#environment will then look like the following
			# bin
			# cmake
			# compiler_compat
			# conda-meta
			# copra_modifications
			# dat
			# data
			# doc
			# docs
			# etc
			# fonts
			# include
			# lib
			# lib64
			# libexec
			# man
			# sbin
			# share
			# ssl
			# var
			# x86_64-conda_cos6-linux-gnu
			# x86_64-conda-linux-gnu

#run this script to save all the original coprarna scripts to separate directories
	#this will then replace them with the modified scripts
mkdir original_scripts

mv ../bin/CopraRNA2.pl \
	../bin/coprarna_aux/get_CDS_from_gbk.pl \
	../bin/coprarna_aux/combine_clusters.pl \
	../bin/coprarna_aux/homology_intaRNA.pl \
	../bin/coprarna_aux/annotate_raw_output.pl \
	../bin/coprarna_aux/compute_weights.pl \
	../bin/coprarna_aux/parse_16s_from_gbk.pl \
	../bin/coprarna_aux/prepare_intarna_out.pl original_scripts/

cp final_coprarna3.pl add_date_omit_incompatible.sh ../bin/

cp get_CDS_from_gbk.pl \
	combine_clusters.pl \
	prokaryotes.txt \
	homology_intaRNA.pl \
	mod_annotate_raw_output.pl \
	mod_compute_weights.pl \
	mod_parse_16s_from_gbk.pl \
	mod_prepare_intarna_out.pl \
	final_build_kegg2refseq.pl ../bin/coprarna_aux/

cd ../bin/
chmod 775 *

cd coprarna_aux/
chmod 775 *