#!/bin/bash
#SBATCH --job-name=batlow_sync2
#SBATCH --partition=Standard
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --output=slurm_%j_batlow_sync.out
#SBATCH --error=slurm_%j_batlow_sync.err

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/paths.sh"

MAPDIR="$BASE/map"
OUTDIR="$BASE/sync"

source /opt/conda/etc/profile.d/conda.sh
conda activate "$CONDA_ENV"

# Resolve PoPoolation2 jar (allow override via config/paths.sh)
if [[ -z "${P2JAR}" ]]; then
  P2JAR="$CONDA_PREFIX/share/popoolation2-1.201-0/mpileup2sync.jar"
fi
test -f "$P2JAR" || { echo "mpileup2sync.jar not found: $P2JAR" >&2; exit 1; }

SCRATCH="$SCR/batlow_sync_${SLURM_JOB_ID}"
mkdir -p "$SCRATCH" "$OUTDIR"

# -------- BAM list --------
# feral: exclude BF1 and BF12 (so start from BF2..)
# managed: keep BM1 and BM12 (include them)
BAMS=(
  "$MAPDIR/batlow_feral/BatlowBF2.bam"
  "$MAPDIR/batlow_feral/BatlowBF3.bam"
  "$MAPDIR/batlow_feral/BatlowBF4.bam"
  "$MAPDIR/batlow_feral/BatlowBF5.bam"
  "$MAPDIR/batlow_feral/BatlowBF6.bam"
  "$MAPDIR/batlow_feral/BatlowBF7.bam"
  "$MAPDIR/batlow_feral/BatlowBF8.bam"
  "$MAPDIR/batlow_feral/BatlowBF9.bam"
  "$MAPDIR/batlow_feral/BatlowBF10.bam"
  "$MAPDIR/batlow_feral/BatlowBF11.bam"
  "$MAPDIR/batlow_feral/BatlowBF13.bam"
  "$MAPDIR/batlow_feral/BatlowBF14.bam"

  "$MAPDIR/batlow_managed/BatlowBM1.bam"
  "$MAPDIR/batlow_managed/BatlowBM2.bam"
  "$MAPDIR/batlow_managed/BatlowBM3.bam"
  "$MAPDIR/batlow_managed/BatlowBM4.bam"
  "$MAPDIR/batlow_managed/BatlowBM5.bam"
  "$MAPDIR/batlow_managed/BatlowBM6.bam"
  "$MAPDIR/batlow_managed/BatlowBM7.bam"
  "$MAPDIR/batlow_managed/BatlowBM8.bam"
  "$MAPDIR/batlow_managed/BatlowBM9.bam"
  "$MAPDIR/batlow_managed/BatlowBM10.bam"
  "$MAPDIR/batlow_managed/BatlowBM11.bam"
  "$MAPDIR/batlow_managed/BatlowBM12.bam"
  "$MAPDIR/batlow_managed/BatlowBM13.bam"
  "$MAPDIR/batlow_managed/BatlowBM14.bam"
)

# check BAM + BAI
for b in "${BAMS[@]}"; do
  [[ -f "$b" ]] || { echo "Missing BAM: $b" >&2; exit 1; }
  [[ -f "${b}.bai" ]] || { echo "Missing BAI: ${b}.bai" >&2; exit 1; }
done

# create mpileup
samtools mpileup -B -f "$REF" "${BAMS[@]}" > "$SCRATCH/batlow_exclF1_F12_keepM1_M12.mpileup"

# mpileup -> sync
java -ea -Xmx28g -jar "$P2JAR" \
  --input  "$SCRATCH/batlow_exclF1_F12_keepM1_M12.mpileup" \
  --output "$SCRATCH/batlow_exclF1_F12_keepM1_M12.sync" \
  --fastq-type sanger \
  --min-qual 20 \
  --threads "$SLURM_CPUS_PER_TASK"

# move result back
mv "$SCRATCH/batlow_exclF1_F12_keepM1_M12.sync" "$OUTDIR/"
rm -rf "$SCRATCH"

echo "DONE: $OUTDIR/batlow_exclF1_F12_keepM1_M12.sync"
