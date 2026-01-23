#!/bin/bash
#SBATCH --job-name=YM_map
#SBATCH --partition=Standard
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=24:00:00
#SBATCH --output=slurm_%A_%a_%x.out
#SBATCH --error=slurm_%A_%a_%x.err
#SBATCH --array=1-10

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/paths.sh"

mkdir -p "$SCR/work/young_managed" "$SCR/map/young_managed" "$BASE/map/young_managed"

IN_DIR="$BASE/fastq_by_genotype/young_managed"
WORK_DIR="$SCR/work/young_managed"
OUT_SCR="$SCR/map/young_managed"
OUT_HOME="$BASE/map/young_managed"

source /opt/conda/etc/profile.d/conda.sh
conda activate "$CONDA_ENV"

mkdir -p "$WORK_DIR" "$OUT_SCR" "$OUT_HOME"
cd "$WORK_DIR"

GENO=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$BASE/meta/young_managed_genotypes.txt")
FQ="$IN_DIR/${GENO}.FASTQ.gz"
test -s "$FQ"

# bwa aln
bwa aln -n 0.01 -l 100 -o 1 -d 12 -e 12 -t "${SLURM_CPUS_PER_TASK}" "$REF" "$FQ" > "$OUT_SCR/${GENO}.sai"
bwa samse "$REF" "$OUT_SCR/${GENO}.sai" "$FQ" > "$OUT_SCR/${GENO}.sam"

# filter
samtools view -q 20 -bS "$OUT_SCR/${GENO}.sam" | samtools sort -o "$OUT_SCR/${GENO}.bam"
samtools index "$OUT_SCR/${GENO}.bam"

# copy results back to home
cp -f "$OUT_SCR/${GENO}.bam" "$OUT_HOME/"
cp -f "$OUT_SCR/${GENO}.bam.bai" "$OUT_HOME/"

# remove big .sam and .sai
rm -f "$OUT_SCR/${GENO}.sam" "$OUT_SCR/${GENO}.sai"

echo "DONE: $GENO"
