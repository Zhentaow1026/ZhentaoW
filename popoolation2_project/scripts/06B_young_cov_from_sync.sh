#!/usr/bin/env bash
set -euo pipefail

SYNC="sync/young_F_vs_M_2pop1.sync"

OUTDIR="results/coverage"
OUT_PREFIX="young_F_vs_M_2pop1"
COV_TSV="${OUTDIR}/${OUT_PREFIX}.coverage.tsv"

mkdir -p "$OUTDIR"
[[ -s "$SYNC" ]] || { echo "Missing/empty SYNC: $SYNC" >&2; exit 1; }

awk -F'\t' 'BEGIN{OFS="\t"}
{
  split($4,a,":"); c1=a[1]+a[2]+a[3]+a[4];
  split($5,b,":"); c2=b[1]+b[2]+b[3]+b[4];
  print c1, c2
}' "$SYNC" > "$COV_TSV"

python - <<PY
import numpy as np, math
cov = np.loadtxt("${COV_TSV}")
c1, c2 = cov[:,0], cov[:,1]

def show(name, x):
    print("==", name, "==")
    print("sites:", len(x))
    print("min:", int(x.min()), "mean:", round(float(x.mean()),1), "max:", int(x.max()))
    for p in [50, 75, 90, 95, 97.5, 99, 99.5]:
        print(f"p{p}:", round(float(np.percentile(x,p)),1))
    print()

show("pop1", c1)
show("pop2", c2)

mc = max(np.percentile(c1,99), np.percentile(c2,99))
print("Suggested --max-coverage:", int(math.ceil(mc)))
print("Wrote:", "${COV_TSV}")
PY
