#!/bin/bash
#SBATCH --job-name=all_regions1_sync
#SBATCH --partition=Standard
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=slurm_%j_all_regions1_sync.out
#SBATCH --error=slurm_%j_all_regions1_sync.err

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/paths.sh"

OUTDIR="$BASE/sync"
BAMLIST="$BASE/meta/all_regions1_bams_order.txt"

source /opt/conda/etc/profile.d/conda.sh
conda activate "$CONDA_ENV"

# Resolve PoPoolation2 jar
if [[ -z "${P2JAR}" ]]; then
  P2JAR="$CONDA_PREFIX/share/popoolation2-1.201-0/mpileup2sync.jar"
fi
test -f "$P2JAR" || { echo "mpileup2sync.jar not found: $P2JAR" >&2; exit 1; }

SCRATCH="$SCR/all_regions1_sync_${SLURM_JOB_ID}"
mkdir -p "$SCRATCH" "$OUTDIR"

# checks
[[ -f "$REF" ]] || { echo "Missing REF: $REF" >&2; exit 1; }
[[ -f "$BAMLIST" ]] || { echo "Missing BAM list: $BAMLIST" >&2; exit 1; }

# verify BAM + BAI exist (order matters!)
while IFS= read -r b; do
  [[ -z "$b" ]] && continue
  [[ -f "$b" ]] || { echo "Missing BAM: $b" >&2; exit 1; }
  [[ -f "$b.bai" ]] || { echo "Missing BAI: $b.bai" >&2; exit 1; }
done < "$BAMLIST"

# mpileup
samtools mpileup -B -f "$REF" -b "$BAMLIST" \
  > "$SCRATCH/all_regions1.mpileup"

# mpileup -> sync
java -ea -Xmx28g -jar "$P2JAR" \
  --input "$SCRATCH/all_regions1.mpileup" \
  --output "$SCRATCH/all_regions1.sync" \
  --fastq-type sanger \
  --min-qual 20 \
  --threads "$SLURM_CPUS_PER_TASK"

# move result back
mv "$SCRATCH/all_regions1.sync" "$OUTDIR/all_regions1.sync"

rm -rf "$SCRATCH"

echo "DONE: $OUTDIR/all_regions1.sync"
echo "ORDER: $BAMLIST"
