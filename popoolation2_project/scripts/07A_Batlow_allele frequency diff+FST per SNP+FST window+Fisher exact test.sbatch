
# step1
#!/bin/bash
#SBATCH --job-name=BL_freqdiff1
#SBATCH --partition=Standard
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=08:00:00
#SBATCH --output=slurm_%j_%x.out
#SBATCH --error=slurm_%j_%x.err


set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../config/paths.sh"

SYNC="$BASE/sync/batlow_F_vs_M_2pop1.sync"
OUT="$BASE/pop2_batlow_2pop1"
LOGDIR="$OUT/logs"
mkdir -p "$OUT" "$LOGDIR"

# conda
source /opt/conda/etc/profile.d/conda.sh
conda activate "$CONDA_ENV"

# check
SCRIPT="$CONDA_PREFIX/bin/snp-frequency-diff.pl"
[[ -f "$SCRIPT" ]] || { echo "Missing script: $SCRIPT" >&2; exit 1; }
[[ -s "$SYNC" ]]   || { echo "Missing/empty SYNC: $SYNC" >&2; exit 1; }

PREFIX="$OUT/batlow_F_vs_M_2pop1"
OUT_PWC="${PREFIX}_pwc"
OUT_RC="${PREFIX}_rc"

perl "$SCRIPT" \
  --input "$SYNC" \
  --output-prefix "$PREFIX" \
  --min-count 6 \
  --min-coverage 50 \
  --max-coverage 5750

echo "DONE step1: $OUT_PWC and $OUT_RC"

#step2：
#!/bin/bash
#SBATCH --job-name=BL_fstSNP1
#SBATCH --partition=Standard
#SBATCH --cpus-per-task=2
#SBATCH --mem=24G
#SBATCH --time=12:00:00
#SBATCH --output=slurm_%j_%x.out
#SBATCH --error=slurm_%j_%x.err

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../config/paths.sh"

SYNC="$BASE/sync/batlow_F_vs_M_2pop1.sync"
OUT="$BASE/pop2_batlow_2pop1"
LOGDIR="$OUT/logs"
mkdir -p "$OUT" "$LOGDIR"

# only one pool-size allowed; keep your value
POOLSIZE=260

source /opt/conda/etc/profile.d/conda.sh
conda activate "$CONDA_ENV"

SCRIPT="$CONDA_PREFIX/bin/fst-sliding.pl"
[[ -f "$SCRIPT" ]] || { echo "Missing script: $SCRIPT" >&2; exit 1; }
[[ -s "$SYNC" ]]   || { echo "Missing/empty SYNC: $SYNC" >&2; exit 1; }

OUT_FST="$OUT/batlow_F_vs_M_2pop1.SNP.fst"

perl "$SCRIPT" \
  --input "$SYNC" \
  --output "$OUT_FST" \
  --suppress-noninformative \
  --min-count 6 \
  --min-coverage 50 \
  --max-coverage 5750 \
  --min-covered-fraction 1 \
  --window-size 1 \
  --step-size 1 \
  --pool-size "$POOLSIZE"

echo "DONE step2: $OUT_FST"

#step3：
#!/bin/bash
#SBATCH --job-name=BL_fstW5001
#SBATCH --partition=Standard
#SBATCH --cpus-per-task=2
#SBATCH --mem=24G
#SBATCH --time=12:00:00
#SBATCH --output=slurm_%j_%x.out
#SBATCH --error=slurm_%j_%x.err

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../config/paths.sh"

SYNC="$BASE/sync/batlow_F_vs_M_2pop1.sync"
OUT="$BASE/pop2_batlow_2pop1"
LOGDIR="$OUT/logs"
mkdir -p "$OUT" "$LOGDIR"

POOLSIZE=260
WIN=500
STEP=500

source /opt/conda/etc/profile.d/conda.sh
conda activate "$CONDA_ENV"

SCRIPT="$CONDA_PREFIX/bin/fst-sliding.pl"
[[ -f "$SCRIPT" ]] || { echo "Missing script: $SCRIPT" >&2; exit 1; }
[[ -s "$SYNC" ]]   || { echo "Missing/empty SYNC: $SYNC" >&2; exit 1; }

OUT_FST="$OUT/batlow_F_vs_M_2pop1.W${WIN}.fst"

perl "$SCRIPT" \
  --input "$SYNC" \
  --output "$OUT_FST" \
  --min-count 6 \
  --min-coverage 50 \
  --max-coverage 5750 \
  --min-covered-fraction 1 \
  --window-size "$WIN" \
  --step-size "$STEP" \
  --pool-size "$POOLSIZE"

echo "DONE step3: $OUT_FST"

# step4
#!/bin/bash
#SBATCH --job-name=BL_FET1
#SBATCH --partition=Standard
#SBATCH --cpus-per-task=2
#SBATCH --mem=24G
#SBATCH --time=12:00:00
#SBATCH --output=slurm_%j_%x.out
#SBATCH --error=slurm_%j_%x.err

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../config/paths.sh"

SYNC="$BASE/sync/batlow_F_vs_M_2pop1.sync"
OUT="$BASE/pop2_batlow_2pop1"
LOGDIR="$OUT/logs"
mkdir -p "$OUT" "$LOGDIR"

source /opt/conda/etc/profile.d/conda.sh
conda activate "$CONDA_ENV"

SCRIPT="$CONDA_PREFIX/bin/fisher-test.pl"
[[ -f "$SCRIPT" ]] || { echo "Missing script: $SCRIPT" >&2; exit 1; }
[[ -s "$SYNC" ]]   || { echo "Missing/empty SYNC: $SYNC" >&2; exit 1; }

OUT_FET="$OUT/batlow_F_vs_M_2pop1.fet"

perl "$SCRIPT" \
  --input "$SYNC" \
  --output "$OUT_FET" \
  --min-count 6 \
  --min-coverage 50 \
  --max-coverage 5750 \
  --suppress-noninformative

echo "DONE step4: $OUT_FET"

