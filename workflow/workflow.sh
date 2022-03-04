## Input dirs
dir_fq_raw=data/fastq                  # Dir with original FASTQ files
dir_fa_itsx=results/fasta_itsx         # Dir with ITSx-derived FASTA files

## Output dirs
dir_fa_fix=results/fasta_fixnames      # Dir with FASTA files with fixed headers
dir_fq_itsx=results/fastq_itsx         # Output ITS-only FASTQ files
mkdir -p "$dir_fa_fix" "$dir_fq_itsx"

## Fix FASTA headers
for fa_in in "$dir_fa_itsx"/*fasta; do
    fa_out="$dir_fa_fix"/$(basename "$fa_in")
    echo -e "\n-----------\nFrom $fa_in to $fa_out"
    
    ## Remove extra text after a `|`, which seems to be info added (by ITSx, I guess) about the ITS hit
    sed -E 's/>(.*)\|.*/>\1/' "$fa_in" > "$fa_out"
    
    ls -lh "$fa_in" "$fa_out"
done

## Convert itsx-FASTA back to FASTQ
sbatch scripts/fa2fqBr.sh "$dir_fa_fix" "$dir_fq_raw" "$dir_fq_itsx"
