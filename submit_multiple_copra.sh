#!/bin/bash 

#SBATCH --time=48:00:00					##(day-hour:minute:second) sets the max time for the job
#SBATCH --cpus-per-task=8	 			##request number of cpus
#SBATCH --mem=48G						##max ram for the job

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=bienvenido.tibbs-cortes@usda.gov		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="00_copra_masterscript_%j"		##names what slurm logfile will be saved to 

#accept user input
runcode=$1
upstreamdist=$2
downstreamdist=$3
regiontype=$4

#if runcode is left empty, then give it a random string
runcode="${runcode:-$(openssl rand -hex 4)}"

#this script submits multiple copraRNA jobs
#keeps things separated so that crashes don't affect the entire run
#does the preparation for the inputs
envpath="/project/ibdru_bioinformatics/Ben/conda_envs/mod_copra_env"

#need to activate conda environment for final_build_kegg2refseq.pl
#conda install coprarna bioconda::perl-lwp-protocol-https
module load miniconda
source activate ${envpath}

#pull prokaryotes.txt from ncbi and convert to unix
#can take forever if run through sbatch, so might be worth it to just pull it manually
	#wget ftp://ftp.ncbi.nih.gov/genomes/GENOME_REPORTS/prokaryotes.txt
	#dos2unix prokaryotes.txt
	cp ${envpath}/copra_modifications/prokaryotes.txt ./

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

