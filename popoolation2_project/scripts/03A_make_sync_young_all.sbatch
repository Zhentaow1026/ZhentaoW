#!/bin/bash
#SBATCH --job-name=young_sync
#SBATCH --partition=Standard
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=slurm_%j_young_sync.out
#SBATCH --error=slurm_%j_young_sync.err

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/paths.sh"

MAPDIR="$BASE/map"
OUTDIR="$BASE/sync"

SCRATCH="$SCR/young_sync_$SLURM_JOB_ID"
mkdir -p "$SCRATCH" "$OUTDIR"

source /opt/conda/etc/profile.d/conda.sh
conda activate "$CONDA_ENV"

# Resolve PoPoolation2 jar (allow override via config/paths.sh)
if [[ -z "${P2JAR}" ]]; then
  P2JAR="$CONDA_PREFIX/share/popoolation2-1.201-0/mpileup2sync.jar"
fi
test -f "$P2JAR" || { echo "mpileup2sync.jar not found: $P2JAR" >&2; exit 1; }

# build BAM lists
BAMS=(
  "$MAPDIR/young_feral/YoungBF1.bam"
  "$MAPDIR/young_feral/YoungBF2.bam"
  "$MAPDIR/young_feral/YoungBF3.bam"
  "$MAPDIR/young_feral/YoungBF4.bam"
  "$MAPDIR/young_feral/YoungBF5.bam"
  "$MAPDIR/young_feral/YoungBF6.bam"
  "$MAPDIR/young_feral/YoungBF7.bam"
  "$MAPDIR/young_feral/YoungBF8.bam"
  "$MAPDIR/young_feral/YoungBF9.bam"
  "$MAPDIR/young_feral/YoungBF10.bam"
  "$MAPDIR/young_managed/YoungBM1.bam"
  "$MAPDIR/young_managed/YoungBM2.bam"
  "$MAPDIR/young_managed/YoungBM3.bam"
  "$MAPDIR/young_managed/YoungBM4.bam"
  "$MAPDIR/young_managed/YoungBM5.bam"
  "$MAPDIR/young_managed/YoungBM6.bam"
  "$MAPDIR/young_managed/YoungBM7.bam"
  "$MAPDIR/young_managed/YoungBM8.bam"
  "$MAPDIR/young_managed/YoungBM9.bam"
  "$MAPDIR/young_managed/YoungBM10.bam"
)

# check
for b in "${BAMS[@]}"; do
  [[ -f "$b" ]] || { echo "Missing BAM: $b" >&2; exit 1; }
  [[ -f "${b}.bai" ]] || { echo "Missing BAI: ${b}.bai" >&2; exit 1; }
done

# create mpileup
samtools mpileup -B -f "$REF" "${BAMS[@]}" > "$SCRATCH/young_all.mpileup"

# mpileup → sync
java -ea -Xmx28g -jar "$P2JAR" \
  --input  "$SCRATCH/young_all.mpileup" \
  --output "$SCRATCH/young_all.sync" \
  --fastq-type sanger \
  --min-qual 20 \
  --threads "$SLURM_CPUS_PER_TASK"

# move location and remove
mv "$SCRATCH/young_all.sync" "$OUTDIR/"
rm -rf "$SCRATCH"

echo "DONE: $OUTDIR/young_all.sync"
