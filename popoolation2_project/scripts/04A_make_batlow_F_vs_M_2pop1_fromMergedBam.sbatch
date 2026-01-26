cat > /mnt/data/wright/home/u8021786/popoolation2_project/make_batlow_F_vs_M_2pop1_fromMergedBam.sbatch <<'EOF'
#!/bin/bash
#SBATCH --job-name=batlow_2pop_sync
#SBATCH --partition=Standard
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH --time=24:00:00
#SBATCH --output=/mnt/data/wright/home/u8021786/popoolation2_project/slurm_%j_batlow_2pop_sync.out
#SBATCH --error=/mnt/data/wright/home/u8021786/popoolation2_project/slurm_%j_batlow_2pop_sync.err

set -euo pipefail

BASE=/mnt/data/wright/home/u8021786/popoolation2_project
REF=$BASE/ref/Amel_HAv3.1.fna
MAPDIR=$BASE/map
OUTDIR=$BASE/sync

source /opt/conda/etc/profile.d/conda.sh
conda activate popoolation2

# mpileup2sync.jar location
P2JAR="$CONDA_PREFIX/share/popoolation2-1.201-0/mpileup2sync.jar"
[[ -f "$P2JAR" ]] || { echo "Missing mpileup2sync.jar: $P2JAR" >&2; exit 1; }

SCRATCH=/mnt/data/wright/home/scratch/u8021786/batlow_2pop_sync_$SLURM_JOB_ID
mkdir -p "$SCRATCH" "$OUTDIR"


# 1) input BAM list

FERAL_BAMS=(
  $MAPDIR/batlow_feral/BatlowBF2.bam
  $MAPDIR/batlow_feral/BatlowBF3.bam
  $MAPDIR/batlow_feral/BatlowBF4.bam
  $MAPDIR/batlow_feral/BatlowBF5.bam
  $MAPDIR/batlow_feral/BatlowBF6.bam
  $MAPDIR/batlow_feral/BatlowBF7.bam
  $MAPDIR/batlow_feral/BatlowBF8.bam
  $MAPDIR/batlow_feral/BatlowBF9.bam
  $MAPDIR/batlow_feral/BatlowBF10.bam
  $MAPDIR/batlow_feral/BatlowBF11.bam
  $MAPDIR/batlow_feral/BatlowBF13.bam
  $MAPDIR/batlow_feral/BatlowBF14.bam
)

# 2) check

[[ ${#FERAL_BAMS[@]} -gt 0 ]] || { echo "No feral BAMs listed"; exit 1; }
[[ ${#MANAGED_BAMS[@]} -gt 0 ]] || { echo "No managed BAMs matched: $MAPDIR/batlow_managed/BatlowBM*.bam"; exit 1; }

for b in "${FERAL_BAMS[@]}" "${MANAGED_BAMS[@]}"; do
  [[ -f "$b" ]] || { echo "Missing BAM: $b" >&2; exit 1; }
  [[ -f "$b.bai" ]] || { echo "Missing BAI: $b.bai" >&2; exit 1; }
done

[[ -f "$REF" ]] || { echo "Missing REF: $REF" >&2; exit 1; }


# 3) merge BAMs within group

FERAL_MERGED="$SCRATCH/batlow_feral_merged.bam"
MANAGED_MERGED="$SCRATCH/batlow_managed_merged.bam"

echo "[1/4] Merging feral BAMs -> $FERAL_MERGED"
samtools merge -@ "$SLURM_CPUS_PER_TASK" -f "$FERAL_MERGED" "${FERAL_BAMS[@]}"
samtools index -@ "$SLURM_CPUS_PER_TASK" "$FERAL_MERGED"

echo "[2/4] Merging managed BAMs -> $MANAGED_MERGED"
samtools merge -@ "$SLURM_CPUS_PER_TASK" -f "$MANAGED_MERGED" "${MANAGED_BAMS[@]}"
samtools index -@ "$SLURM_CPUS_PER_TASK" "$MANAGED_MERGED"


# 4) mpileup + mpileup2sync-----2-pop sync----tutorial

MPI="$SCRATCH/batlow_F_vs_M_2pop1.mpileup"
SYNC_OUT="$SCRATCH/batlow_F_vs_M_2pop1.sync"

echo "[3/4] mpileup (2 BAMs) -> $MPI"
samtools mpileup -B -f "$REF" "$FERAL_MERGED" "$MANAGED_MERGED" > "$MPI"

echo "[4/4] mpileup2sync -> $SYNC_OUT"
java -Xmx44g -jar "$P2JAR" \
  --input "$MPI" \
  --output "$SYNC_OUT" \
  --fastq-type sanger \
  --min-qual 20 \
  --threads "$SLURM_CPUS_PER_TASK"

# move output
mv "$SYNC_OUT" "$FINAL_SYNC"

echo "DONE: $FINAL_SYNC"
rm -rf "$SCRATCH"
EOF
