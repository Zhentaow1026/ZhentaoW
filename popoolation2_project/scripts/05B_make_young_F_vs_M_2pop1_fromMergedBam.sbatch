#!/bin/bash
#SBATCH --job-name=young_2pop_sync
#SBATCH --partition=Standard
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH --time=24:00:00
#SBATCH --output=slurm_%j_young_2pop_sync.out
#SBATCH --error=slurm_%j_young_2pop_sync.err

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/paths.sh"

MAPDIR="$BASE/map"
OUTDIR="$BASE/sync"
mkdir -p "$OUTDIR"

source /opt/conda/etc/profile.d/conda.sh
conda activate "$CONDA_ENV"

# mpileup2sync.jar location (keep your original style; allow override via paths.sh)
if [[ -z "${P2JAR:-}" ]]; then
  P2JAR="$CONDA_PREFIX/share/popoolation2-1.201-0/mpileup2sync.jar"
fi
[[ -f "$P2JAR" ]] || { echo "Missing mpileup2sync.jar: $P2JAR" >&2; exit 1; }

SCRATCH="$SCR/young_2pop_sync_$SLURM_JOB_ID"
mkdir -p "$SCRATCH"

# 1) collect BAM list
mapfile -t FERAL_BAMS   < <(ls -1 "$MAPDIR/young_feral/YoungBF"*.bam   2>/dev/null | sort -V)
mapfile -t MANAGED_BAMS < <(ls -1 "$MAPDIR/young_managed/YoungBM"*.bam 2>/dev/null | sort -V)

# 2) check
[[ ${#FERAL_BAMS[@]} -gt 0 ]]   || { echo "No feral BAMs matched: $MAPDIR/young_feral/YoungBF*.bam" >&2; exit 1; }
[[ ${#MANAGED_BAMS[@]} -gt 0 ]] || { echo "No managed BAMs matched: $MAPDIR/young_managed/YoungBM*.bam" >&2; exit 1; }

for b in "${FERAL_BAMS[@]}" "${MANAGED_BAMS[@]}"; do
  [[ -f "$b" ]] || { echo "Missing BAM: $b" >&2; exit 1; }
  [[ -f "$b.bai" ]] || { echo "Missing BAI: $b.bai" >&2; exit 1; }
done

# 10 pools each
[[ ${#FERAL_BAMS[@]} -eq 10 ]]   || { echo "Expected 10 feral BAMs, got ${#FERAL_BAMS[@]}" >&2; exit 1; }
[[ ${#MANAGED_BAMS[@]} -eq 10 ]] || { echo "Expected 10 managed BAMs, got ${#MANAGED_BAMS[@]}" >&2; exit 1; }

[[ -f "$REF" ]] || { echo "Missing REF: $REF" >&2; exit 1; }

# 3) merge BAMs within group
FERAL_MERGED="$SCRATCH/young_feral_merged.bam"
MANAGED_MERGED="$SCRATCH/young_managed_merged.bam"

echo "[1/4] Merging feral -> $FERAL_MERGED"
samtools merge -@ "$SLURM_CPUS_PER_TASK" -f "$FERAL_MERGED" "${FERAL_BAMS[@]}"
samtools index -@ "$SLURM_CPUS_PER_TASK" "$FERAL_MERGED"

echo "[2/4] Merging managed -> $MANAGED_MERGED"
samtools merge -@ "$SLURM_CPUS_PER_TASK" -f "$MANAGED_MERGED" "${MANAGED_BAMS[@]}"
samtools index -@ "$SLURM_CPUS_PER_TASK" "$MANAGED_MERGED"

# 4) mpileup + mpileup2sync------2-pop sync
MPI="$SCRATCH/young_F_vs_M_2pop1.mpileup"
SYNC_OUT="$SCRATCH/young_F_vs_M_2pop1.sync"
FINAL_SYNC="$OUTDIR/young_F_vs_M_2pop1.sync"

echo "[3/4] mpileup -> $MPI"
samtools mpileup -B -f "$REF" "$FERAL_MERGED" "$MANAGED_MERGED" > "$MPI"

echo "[4/4] mpileup2sync -> $SYNC_OUT"
java -Xmx44g -jar "$P2JAR" \
  --input "$MPI" \
  --output "$SYNC_OUT" \
  --fastq-type sanger \
  --min-qual 20 \
  --threads "$SLURM_CPUS_PER_TASK"

mv "$SYNC_OUT" "$FINAL_SYNC"

echo "DONE: $FINAL_SYNC"
rm -rf "$SCRATCH"
