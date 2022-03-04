#!/bin/bash

#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --time=12:00:00
#SBATCH --account=PAS0471
#SBATCH --job-name=fa2fq
#SBATCH --output=slurm-fa2fq-%j.out

# Software - making doubly sure this is all loaded:
module load gnu/9.1.0
module load mkl/2019.0.5
module load R/4.0.2
FA2FQ_SCRIPT=bin/itsx_fastq_extractor.r

# Pre-setup
set -e -u -o pipefail    # Run bash in "safe mode", basically

# Command-line arguments
indir_fa=$1
indir_fq=$2
outdir=$3

# Global variables
CURRENTTIME=$(date +"%I:%M %p")

# Create output directory if it doesn't already exist:
mkdir -p "$outdir"

# Report:
echo -e "\n[$CURRENTTIME] Starting itsx script."
echo "[$CURRENTTIME] Input dir:       $indir_fa"
echo "[$CURRENTTIME] Output dir:      $outdir"
echo -e "[$CURRENTTIME] Looping through input files..."

# Get input files
F1=($(ls -1v $indir_fa/*.full.fasta))
F2=($(ls -1v $indir_fq/*.fq))

for i in "${!F2[@]}"; do
    # Files setup
    R1=$(basename ${F1[i]}) # Get basename (i.e 3178_sample_MM-10.full.fasta)
    R2=${R1%.full.fasta}    # Get sample name (i.e 3178_sample_MM-10)
    
    IN1=${F1[i]}
    IN2=${F2[i]}
    OUT=$outdir/$R2.fq
    
    # # Report
    echo -e "[$CURRENTTIME] Processing: \n \t\t $IN1 \t\t$IN2"
    
    # Run ITSx
    Rscript "$FA2FQ_SCRIPT" \
        -f "$IN1" \
        -q "$IN2" \
        -o "$OUT" \
        --threads "$SLURM_CPUS_PER_TASK"
done

echo -e "\n-----------------------"
echo "Listing output files:"
ls -lh "$outdir"
echo
echo -e "[$CURRENTTIME] Done with itsx script.\n"
date
