#!/bin/bash 

#SBATCH --time=48:00:00					##(day-hour:minute:second) sets the max time for the job
#SBATCH --cpus-per-task=40	 			##request number of cpus
#SBATCH --mem=80G						##max ram for the job

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=bienvenido.tibbs-cortes@usda.gov		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="00_copra_slurmlog_%j"		##names what slurm logfile will be saved to 

#take input from batch file
fasta=$1
runcode=$2
upstreamdist=$3
downstreamdist=$4
regiontype=$5
intaparams=$6

#working in a conda environment, so activate it first
module load miniconda
source activate /project/ibdru_bioinformatics/Ben/conda_envs/mod_copra_env/

#call copraRNA
#ntup/ntdown - areas to search around target region
#region - cds for entire transcript
#don't call enrich because DAVID has extremely limited genomes
	#therefore, it generally won't work for organisms that aren't extensively studied

final_coprarna3.pl -srnaseq $fasta -runname $runcode -ntup $upstreamdist -ntdown $downstreamdist -region $regiontype -topcount 200 -cores 40 --verbose --cons 2 --intarna_file $intaparams
